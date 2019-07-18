#!/usr/bin/env bash

cd "$HOME" || exit
cat docker_password.txt | docker login --username {{ dockerhub_user }} --password-stdin
