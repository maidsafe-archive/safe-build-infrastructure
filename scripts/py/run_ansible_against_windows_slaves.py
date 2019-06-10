#!/usr/bin/python

import boto3
import os
import sys
import subprocess
from shutil import rmtree
from time import sleep

def get_windows_slave_instances(environment):
    client = boto3.client('ec2')
    response = client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['windows_slave*']
            },
            {
                'Name': 'tag:environment',
                'Values': [environment]
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )
    return response['Reservations']

def get_decrypted_password(instance_id, environment):
    """
    Unfortunately the Python boto3 interface for get-password-data is a bit different
    from the interface on the CLI. The CLI has a parameter for supplying the private
    key that the instance was launched with, and that key is then used to decrypt the
    password. With boto3, get_password_data returns the password in its encrypted form
    and it has no ability to specify the key. This means you need to decrypt it yourself
    after retrieving it.

    I did try to do this, but all the examples I found were years out of date and didn't
    work correctly. It would have taken me all day to figure out how to get the correct
    library (there are several) for decrypting the password in this script, so I'm going
    with this hacky method, which is to call out to a script that uses the CLI.

    The CLI can just reference the private key to decrypt, which is so much simpler.
    I really don't know why they didn't add this functionality to the boto3 API.
    """
    p = subprocess.Popen(
        './scripts/sh/get_windows_password.sh "{0}" "{1}"'.format(
            environment, instance_id),
         stdout=subprocess.PIPE, shell=True)
    (output, _) = p.communicate()
    p.wait()
    print("Retrieved password for instance {0}".format(instance_id))
    return output.strip()

def get_jenkins_master_location(environment):
    client = boto3.client('ec2')
    response = client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['jenkins_master']
            },
            {
                'Name': 'tag:environment',
                'Values': [environment]
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )
    if environment == 'dev':
        return response['Reservations'][0]['Instances'][0]['PublicDnsName']
    return response['Reservations'][0]['Instances'][0]['PrivateIpAddress']

def print_jenkins_master_location(environment):
    if environment == 'dev':
        client = boto3.client('ec2')
        response = client.describe_instances(
            Filters=[
                {
                    'Name': 'tag:Name',
                    'Values': ['jenkins_master']
                },
                {
                    'Name': 'tag:environment',
                    'Values': [environment]
                },
                {
                    'Name': 'instance-state-name',
                    'Values': ['running']
                }
            ]
        )
        print('You can now access Jenkins on http://{0}.'.format(response['Reservations'][0]['Instances'][0]['PublicDnsName']))
        print('Note that some machines may not be available until after they have rebooted.')
    elif environment == 'prod':
        print('You can now access Jenkins on https://jenkins.maidsafe.net/.')
        print('Note that some machines may not be available until after they have rebooted.')
    elif environment == 'staging':
        print('You can now access Jenkins on https://jenkins-staging.maidsafe.net/.')
        print('Note that some machines may not be available until after they have rebooted.')
    elif environment == 'qa':
        print('You can now access Jenkins on https://jenkins-qa.maidsafe.net/.')
        print('Note that some machines may not be available until after they have rebooted.')

def wait_for_instance_password_to_become_available(instance_id):
    client = boto3.client('ec2')
    password_data = client.get_password_data(InstanceId=instance_id)['PasswordData']
    while not password_data:
        print('Password not yet available for {0}. Sleeping for 5 seconds before retry...'
              .format(instance_id))
        sleep(5)
        password_data = client.get_password_data(InstanceId=instance_id)['PasswordData'].strip()

def get_slaves_name_info_map(instances, environment):
    slaves_name_info_map = {}
    for instance in instances:
        machine_name = next(
            tag['Value'] for tag in
            instance['Instances'][0]['Tags']
            if tag['Key'] == 'Name')
        instance_id = instance['Instances'][0]['InstanceId']
        wait_for_instance_password_to_become_available(instance_id)
        slaves_name_info_map[machine_name] = \
            (get_decrypted_password(instance_id, environment), instance_id)
    return slaves_name_info_map

def get_ansible_vault_password_path():
    return os.path.expanduser('~/.ansible/vault-pass')

def set_password_for_ansible_user(slave_name, slave_password, environment, ec2_ini_file):
    # Using the environment variable is to deal with passwords that have special
    # characters in them. The Ansible command here gets passed to a shell and it doesn't
    # parse the password correctly if it has special symbols in it.
    os.environ['WINDOWS_ADMIN_PASSWORD'] = '{0}'.format(slave_password)
    print("Set admin password for ansible user on {0}...".format(slave_name))
    cmd = "EC2_INI_PATH='environments/{0}/{1}' ".format(environment, ec2_ini_file)
    cmd += "ansible-playbook -i 'environments/{0}' ".format(environment)
    cmd += "--vault-password-file={0} ".format(get_ansible_vault_password_path())
    cmd += "--limit={0} ".format(slave_name)
    cmd += '-e "ansible_user=Administrator" '
    cmd += '-e "ansible_password=$WINDOWS_ADMIN_PASSWORD" '
    cmd += "ansible/win-ansible-user.yml"
    run_ansible(cmd, clear_cache=False)

def jenkins_slave_ansible_run(environment, ec2_ini_file):
    if environment not in ['dev', 'staging', 'prod']:
        raise ValueError("The environment '{0}' is not supported".format(environment))
    password_variable = '$WINDOWS_{0}_ANSIBLE_USER_PASSWORD'.format(environment.upper())
    print("Running Ansible against Windows slaves... (can be 10+ seconds before output)")
    cmd = "EC2_INI_PATH='environments/{0}/{1}' ".format(environment, ec2_ini_file)
    cmd += "ansible-playbook -i 'environments/{0}' ".format(environment)
    cmd += "--vault-password-file={0} ".format(get_ansible_vault_password_path())
    cmd += '-e "cloud_environment={0}" '.format(environment)
    cmd += '-e "jenkins_master_dns={0}" '.format(get_jenkins_master_location(environment))
    cmd += '-e "ansible_password={0}" '.format(password_variable)
    cmd += "ansible/win-jenkins-slave.yml"
    run_ansible(cmd)

def run_ansible(cmd, clear_cache=True):
    print(cmd)
    ansible_tmp_path = os.path.expanduser('~/.ansible/tmp')
    if clear_cache:
        if os.path.exists(ansible_tmp_path):
            rmtree(os.path.expanduser('~/.ansible/tmp'))
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    while True:
        out = p.stdout.read(1)
        if out == '' and p.poll() != None:
            break
        if out != '':
            sys.stdout.write(out)
            sys.stdout.flush()

def reboot_slaves(slaves_info):
    print("Issuing reboots for all Windows slaves...")
    client = boto3.client('ec2')
    client.reboot_instances(InstanceIds=[y[1] for x, y in slaves_info.iteritems()])

def main():
    if len(sys.argv) == 1:
        print("Please supply the environment name. Valid values are 'dev', 'staging' or 'prod'.")
        return 1
    environment = sys.argv[1]
    ec2_ini_file = 'ec2.ini'
    if len(sys.argv) == 3:
        ec2_ini_file = sys.argv[2]
    slaves = get_slaves_name_info_map(
        get_windows_slave_instances(environment), environment)
    for machine_name, slave_info in slaves.iteritems():
        set_password_for_ansible_user(
            machine_name, slave_info[0], environment, ec2_ini_file)
    jenkins_slave_ansible_run(environment, ec2_ini_file)
    print_jenkins_master_location(environment)
    reboot_slaves(slaves)
    return 0

if __name__ == '__main__':
    sys.exit(main())
