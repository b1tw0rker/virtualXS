#!/usr/bin/python3

import os

dir001 = "/tmp/.virtualXS"
if not os.path.isdir(dir001):
    os.mkdir(dir001)

OS = "ROCKY" if os.path.isfile("/etc/rocky-release") else None
if OS:
    with open("/etc/rocky-release") as f:
        version = f.read().split()[3]

u_version = "1.1.20"
u_ip4 = os.popen("hostname --all-ip-addresses").read().split()[0]
u_hostname = os.popen("hostname").read().strip()
u_client_ip = os.environ.get("SSH_CLIENT", "").split()[0]
u_path = "/opt/virtualXS"
u_server = "w"
u_iface = "eth0"
u_aws = "n"
u_all = "n"

os.system("timedatectl set-timezone Europe/Berlin")
os.system(f"hostnamectl set-hostname {u_hostname}")

print("********************************************************************")
print("*                                                                  *")
print(f"*            Welcome to VirtualXS Install - Version {u_version}         *")
print(f"*                    Detected OS: {OS} - Version: {version}             *")
print("*                                                                  *")
print("********************************************************************")
print()

disclaimer_file = os.path.join(dir001, "disclaimer")
if not os.path.isfile(disclaimer_file):
    u_disclaimer = input("ATTENTION: This script is designed ONLY on freshly installed server. DO NOT USE THIS SCRIPT ON A PRODUCTION MACHINE!!! To confirm this, type: \"install\" to go on: ")
    if u_disclaimer != "install":
        exit()
    open(disclaimer_file, "w").close()

u_ip = input("Set Server IP address: ") or u_ip4
u_srv = input("Set Servername (FQDN): ") or u_hostname
u_domain = input("Domain (eg. domain.tld): ") or ".".join(u_srv.split(".")[1:])
u_client_ip = input("Your IP (Client IP): ") or u_client_ip

interface_file = os.path.join(dir001, "interface")
if os.path.isfile(interface_file):
    with open(interface_file) as f:
        INTERFACE = f.read().strip()
    u_iface = input("NetzwerkSchnittstelle: ") or INTERFACE
else:
    u_iface = input("NetzwerkSchnittstelle: ") or u_iface
    with open(interface_file, "w") as f:
        f.write(u_iface)

u_mysql_pwd = input("Upcoming MySQL root password: ")
u_server = input("Create Web or DNS Server [w/d]: ") or u_server
u_aws = input("Create on AWS [y/N]: ") or u_aws
