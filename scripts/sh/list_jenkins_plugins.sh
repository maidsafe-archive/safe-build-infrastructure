#!/usr/bin/env bash

sudo yum install -y perl

echo
echo "please provide your jenkins host"
read -r host
echo "please provide your jenkins username"
read -r username
echo "please provide your password"
read -r -s password

export JENKINS_HOST=$username:$password@$host
curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g' | sed 's/ /:/' | sort
