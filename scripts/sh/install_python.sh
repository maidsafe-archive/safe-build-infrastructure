#!/usr/bin/env bash

# When installing python-pip, there are sometimes prompts for user input.
# Declaring the DEBIAN_FRONTEND variable will bypass those prompts.
sed -Ei 's/^(.*ubuntu.* main)$/\1 universe/' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python
apt-get install -y python-pip
