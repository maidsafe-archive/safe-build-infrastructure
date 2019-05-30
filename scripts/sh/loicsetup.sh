#!/bin/bash

apt install apt-transport-https dirmngr
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu vs-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-vs.list
apt update
sudo apt-get install monodevelop -y

sudo apt-get install git-core -y

git clone https://github.com/NewEraCracker/LOIC.git
cd LOIC
./loic.sh install
