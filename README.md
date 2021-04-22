# virtualXS
Utility Script to create a Virtual Hosting Server out of the box. The script performs to optimize a RHEL8 Minmal or Centos8 Minimal Server for hosting purpose.

# WARNING:
THIS SCRIPT COMES WITH ABSOLUTE NO WARRANTY, 
THIS SCRIPT IS ABSOLUTE BETA STUFF. DO NOT USE IT ON PRODUCTION SYSTEMS

(C) 2021 by Dipl. Wirt.-Ing. Nick Herrmann
This program is WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

virtualXS will be distributed by dnf. To install the programm on your RHEL8 or CentOS 8 installation, follow the following three steps:

-1- Import the RPM-GPG Key to your system by typing:

rpm --import https://srv.bit-worker.com/repository/RPM-GPG-KEY-BitWorker

-2- Install the BitWorker Repository by adding the Repo to your server:

dnf config-manager --add-repo https://srv.bit-worker.com/repository/bitworker.repo

-3- Now you can install "virtualXS" on your system:

dnf install virtualXS

Thats it! After a successfull installation the script will take his place here: /opt/virtualXS.

By running the new command "vxs" (placed in: /usr/local/bin/vxs) on the shell, the script start's to optimize your machine for virtual hosting purpose.

Thats it folks!
