$jenkins_master_url = "http://{{ jenkins_master_url }}:8080"
$jenkins_user = "{{ jenkins_admin_user }}"
$jenkins_password = "{{ secret_jenkins_admin_user_password }}"
$slave_name = "{{ windows_rust_slave_full_name }}"

wget.exe --user=$jenkins_user --password=$jenkins_password --auth-no-challenge -q -O crumb.xml $jenkins_master_url/crumbIssuer/api/xml
[xml]$crumbXml = Get-Content 'crumb.xml'
$crumb = "Jenkins-Crumb:" + $crumbXml.selectNodes('//defaultCrumbIssuer/crumb')[0].InnerText

wget.exe --user=$jenkins_user --password=$jenkins_password --header=$crumb --auth-no-challenge -q -O slave-agent.jnlp $jenkins_master_url/computer/$slave_name/slave-agent.jnlp

[xml]$xml = Get-Content 'slave-agent.jnlp'
$secret_key = $xml.selectNodes('//application-desc/argument')[0].InnerText
echo $secret_key

rm slave-agent.jnlp
rm crumb.xml
