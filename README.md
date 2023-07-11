# virtualXS

## Disclaimer

The Python part of this script is still in development and not usable in this state.

##

virtualXS is a smart swiss knife utility script to create a Virtual-Hosting-Server out of the box. This script performs optimizing and securing a Linux Server for hosting purpose.

The following systems are supported:

- RHEL8 (Minimal)
- Centos8 (Minimal)
- Rocky Linux 9.x
- Rocky Linux 8.x
- AWS & Azure machines!

## WARNING:

THIS SCRIPT COMES WITH ABSOLUTE NO WARRANTY,
THIS SCRIPT IS ABSOLUTE BETA STUFF. DO NOT USE IT ON PRODUCTION SYSTEMS

(C) 2021-2023 by Dipl. Wirt.-Ing. Nick Herrmann
This program is WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

virtualXS will be distributed by dnf. To install the programm on your RHEL8 or CentOS 8 installation, follow the following three steps:

## Installation:

-1- Import the RPM-GPG Key to your system:

```bash
rpm --import https://repo.virt-x.de/RPM-GPG-KEY-BitWorker
```

-2- Install the Virt-X Repository by adding the repo to your server:

```bash
dnf config-manager --add-repo https://repo.virt-x.de/virtx.repo
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

08/13/22 - Bugfixes for Rocky Linux 9

07/22/22 - Changed Repo to: repo.virt-x.de. Added Support for Rocky Linux 9

06/03/22 - Bugfix Version and started to prog a Python Version

02/20/22 - Bugfixes, new disclaimer and maria-db support

01/27/22 - Added support for AWS machines.

01/28/22 - Added support for Rocky Linux 8.x

## License

[MIT](https://choosealicense.com/licenses/mit/)
