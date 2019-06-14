#!/usr/bin/env bash

# When installing python-pip, there are sometimes prompts for user input.
# Declaring this variable will bypass those prompts.
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python
apt-get install -y python-pip
