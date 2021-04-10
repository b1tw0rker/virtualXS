# virtualXS
Utility Script to create a Virtual Server out of the box. The script performs to optimize a RHEL8 or Centos8 Minimal Server for hosting purpose.

WARNING: THIS SCRIPT COMES WITH ABSOLUTE NO WARRANTY, 
WARNING: THIS SCRIPT IS ABSOLUE BETA. DO NOT USE IT ON PRODUCTION SYSTEMS

#    (C) 2021 by Dipl. Wirt.-Ing. Nick Herrmann
#
#    This program is WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

virtualXS will be distributed by dnf. To get install the programm on your fresh RHEL8 or CentOS 8 instalaltion do the following Steps:

- Import the RPM-GPG Key to your system by typing:

rpm --import https://srv.bit-worker.com/repository/RPM-GPG-KEY-BitWorker

- Install the BitWorker Reposirity by adding the Repo to your server

dnf config-manager --add-repo https://srv.bit-worker.com/repository/bitworker.repo

- Now you can install "virtualXS" on your system.

dnf install virtualXS

After a successfull installtion the script will take his place in /opt/virtualXS

by running the command "vxs" the script start to opptimize your machine for virtual hosting purpose.

Thats it folks.


