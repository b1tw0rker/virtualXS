# virtualXS

![virtualXS version](https://img.shields.io/badge/version-v1.2.148-green.svg) ![Letztes Update](https://img.shields.io/github/last-commit/b1tw0rker/virtualXS.svg) ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

##

virtualXS is a smart swiss knife utility script to create a Virtual-Hosting-Server out of the box. This script performs optimizing and securing a Linux Server for hosting purpose.

The following systems are supported:

- RHEL10 (Minimal is recommended)
- RHEL9 (Minimal is recommended)
- Rocky Linux 10.x (Minimal is recommended)
- Rocky Linux 9.x (Minimal is recommended)
- AWS and Azure machines.

## WARNING - DISCLAIMER

THIS SCRIPT COMES WITH ABSOLUTE NO WARRANTY,
THIS SCRIPT IS ABSOLUTE BETA STUFF. DO NOT USE IT ON PRODUCTION SYSTEMS

(C) 2021-2026 by Dipl. Wirt.-Ing. Nick Herrmann
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

## Local Certbot DNS Configuration

The file files/certbot/config/dns-config.conf is intentionally not tracked by Git because it may contain provider endpoints and API credentials.

Create your local configuration from the versioned template before using DNS challenge automation:

```bash
cp /opt/virtualXS/files/certbot/config/dns-config.example /opt/virtualXS/files/certbot/config/dns-config.conf
```

That's it folks!

## Changelog

05/09/26 - **Security & Hardening Improvements**
- `certbotcron` umbenannt in `certbot-renew` (klarere Benennung)
- Kernel-Hardening: `99-bw-custom.conf` umbenannt in `99-bw-kernel-hardening.conf`
- Kernel-Hardening erweitert: ASLR, kptr_restrict, ptrace_scope, protected_hardlinks/symlinks, TCP-Timestamps, log_martians
- Neues Modul `lib_kernel_modules.sh`: Deaktivierung ungenutzter Kernel-Module (Drucker, USB-Storage, Bluetooth, ungenutzte Netzwerkprotokolle, exotische Dateisysteme)
- SELinux: Deaktivierung jetzt optional per Setup-Frage (statt automatisch)
- Setup-Fragenummern korrigiert: `x/10` → `x/6`
- `lib_wordpress.sh` in Setup-Flow eingebunden (WP-CLI Installation)
- Beschreibende Texte in Setup-Fragen verbessert (MySQL, Kernel-Hardening, Dovecot-Certbot)
- Firewall: Trennlinie zwischen TODO-Hinweis und Kernel-Hardening-Frage ergänzt

05/05/26 - added RHEL10, Rocky 10 Support

05/24/25 - Some smaller bugfixes , improvment in dovecot

07/27/23 - Documentation work

08/13/22 - Bugfixes for Rocky Linux 9

07/22/22 - Changed Repo to: repo.virt-x.de. Added Support for Rocky Linux 9

06/03/22 - Bugfix Version and started to prog a Python Version

02/20/22 - Bugfixes, new disclaimer and maria-db support

01/27/22 - Added support for AWS machines.

01/28/22 - Added support for Rocky Linux 8.x

## License

[MIT](https://choosealicense.com/licenses/mit/)
