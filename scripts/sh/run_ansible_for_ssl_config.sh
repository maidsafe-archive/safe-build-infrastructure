#!/usr/bin/env bash

cloud_environment=$1
if [[ -z "$cloud_environment" ]]; then
    echo "A value must be supplied for the target environment. Valid values are 'dev' or 'prod'."
    exit 1
fi

function get_proxy_location() {
    if [[ "$cloud_environment" == "qa" ]]; then
        proxy_dns=$(aws ec2 describe-instances \
            --filters \
            "Name=tag:Name,Values=haproxy" \
            "Name=tag:environment,Values=$cloud_environment" \
            "Name=instance-state-name,Values=running" \
            | jq '.Reservations | .[0] | .Instances | .[0] | .PublicDnsName' \
            | sed 's/\"//g')
        jenkins_url="https://$proxy_dns"
    fi
}

function run_ansible() {
    rm -rf ~/.ansible/tmp
    echo "Running Ansible against proxy instance for SSL configuration... (can be 10+ seconds before output)"
    if [[ "$cloud_environment" == "qa" ]]; then
        # The QA environment is not using a URL, so we supply the EC2 DNS name for
        # the self signed certificate. The jenkins_url for staging and prod are defined
        # in group_vars, since those are known values.
        get_proxy_location
        EC2_INI_PATH="environments/qa/ec2-bastion.ini" \
            ansible-playbook -i "environments/qa" \
            --private-key="~/.ssh/ansible_qa" \
            --limit=haproxy \
            --vault-password-file=~/.ansible/vault-pass \
            -e "jenkins_url=$jenkins_url" \
            -e "cloud_environment=$cloud_environment" \
            -u ansible ansible/haproxy-ssl-config.yml
    else
        EC2_INI_PATH="environments/qa/ec2-bastion.ini" \
            ansible-playbook -i "environments/qa" \
            --private-key="~/.ssh/ansible_qa" \
            --limit=haproxy \
            --vault-password-file=~/.ansible/vault-pass \
            -e "cloud_environment=$cloud_environment" \
            -u ansible ansible/haproxy-ssl-config.yml
    fi
}

run_ansible
