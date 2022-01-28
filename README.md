# virtualXS

virtualXS is a smart little utility Script to create a Virtual-Hosting-Server out of the box. The script performs optimizing and securing a RHEL8 Minimal or Centos8 Minimal Server for hosting purpose.

## WARNING:

THIS SCRIPT COMES WITH ABSOLUTE NO WARRANTY,
THIS SCRIPT IS ABSOLUTE BETA STUFF. DO NOT USE IT ON PRODUCTION SYSTEMS

(C) 2021-2022 by Dipl. Wirt.-Ing. Nick Herrmann
This program is WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

virtualXS will be distributed by dnf. To install the programm on your RHEL8 or CentOS 8 installation, follow the following three steps:

## Installation:

-1- Import the RPM-GPG Key to your system:

```bash
rpm --import https://srv002.bit-worker.com/repository/RPM-GPG-KEY-BitWorker
```

-2- Install the BitWorker Repository by adding the Repo to your server:

```bash
dnf config-manager --add-repo https://srv002.bit-worker.com/repository/bitworker.repo
```

If the shell aborts with an error: No such command: config-manager. Install the core plugins:

```bash
dnf install dnf-plugins-core
```

-3- Now you can install "virtualXS" on your system:

```bash
dnf -y install virtualXS
```

That's it! After a successfull installation the script will take his place here: /opt/virtualXS.

By running the new command

```bash
vxs
```

(which is placed in: /usr/local/bin/vxs) on the shell, the script start's to optimize your machine for virtual hosting purpose.

That's it folks!

## Changelog

28/01/22 - Added support for AWS machines.
28/01/22 - Added support for Rocky 8 Linux

## License

[MIT](https://choosealicense.com/licenses/mit/)
