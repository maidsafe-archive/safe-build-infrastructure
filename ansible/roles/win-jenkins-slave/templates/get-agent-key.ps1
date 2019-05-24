$jenkins_master_url = "http://{{ jenkins_master_dns }}"
$jenkins_user = "{{ jenkins_admin_user }}"
$jenkins_password = "{{ secret_jenkins_admin_user_password }}"
{% if cloud_environment != "none" %}
$slave_name = "{{ ec2_tag_full_name }}"
{% else %}
$slave_name = "{{ windows_rust_slave_full_name }}"
{% endif %}

curl.exe -s --user ${jenkins_user}:${jenkins_password} $jenkins_master_url/crumbIssuer/api/xml > crumb.xml
[xml]$crumbXml = Get-Content 'crumb.xml'
$crumb = "Jenkins-Crumb:" + $crumbXml.selectNodes('//defaultCrumbIssuer/crumb')[0].InnerText

curl.exe -s --header $crumb --user ${jenkins_user}:${jenkins_password} $jenkins_master_url/computer/$slave_name/slave-agent.jnlp > slave-agent.jnlp

[xml]$xml = Get-Content 'slave-agent.jnlp'
$secret_key = $xml.selectNodes('//application-desc/argument')[0].InnerText
echo $secret_key

rm slave-agent.jnlp
rm crumb.xml
