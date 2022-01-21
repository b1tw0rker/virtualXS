### https://opensource.com/article/18/9/how-build-rpm-packages
### https://rpm-packaging-guide.github.io/
###
Summary: Utility Script to create a Virtual Server out of the box
Name: virtualXS
Version: 1.0.56
Release: 1
License: GPL
URL: https://www.bit-worker.com
Group: System
Packager: Dipl. Wirt.-Ing. Nick Herrmann
Requires: bash
BuildRoot: ~/rpmbuild/

# Build with the following syntax:
# rpmbuild --target noarch -bb virtualXS.spec

%description
A collection of utility scripts for setting up a fully virtual machine environment in order to serve a lot of domains to the world.

%prep
################################################################################
# Create the build tree and copy the files from the development directories    #
# into the build tree.                                                         #
################################################################################
echo "BUILDROOT = $RPM_BUILD_ROOT"
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/backup
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/bitworker
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/certbot
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/dovecot
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/firewall
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/httpd
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/mysql
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/postfix
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/powerdns
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/rpm
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/ssh
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/files/vsftpd
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/lib
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/gui
mkdir -p $RPM_BUILD_ROOT/opt/virtualXS/sources

cp /opt/virtualXS/vxs $RPM_BUILD_ROOT/opt/virtualXS
cp /opt/virtualXS/files/backup/* $RPM_BUILD_ROOT/opt/virtualXS/files/backup
cp /opt/virtualXS/files/bitworker/* $RPM_BUILD_ROOT/opt/virtualXS/files/bitworker
cp /opt/virtualXS/files/certbot/* $RPM_BUILD_ROOT/opt/virtualXS/files/certbot
cp /opt/virtualXS/files/dovecot/* $RPM_BUILD_ROOT/opt/virtualXS/files/dovecot
cp /opt/virtualXS/files/firewall/* $RPM_BUILD_ROOT/opt/virtualXS/files/firewall
cp /opt/virtualXS/files/httpd/* $RPM_BUILD_ROOT/opt/virtualXS/files/httpd
cp /opt/virtualXS/files/mysql/* $RPM_BUILD_ROOT/opt/virtualXS/files/mysql
cp /opt/virtualXS/files/postfix/* $RPM_BUILD_ROOT/opt/virtualXS/files/postfix
cp /opt/virtualXS/files/powerdns/* $RPM_BUILD_ROOT/opt/virtualXS/files/powerdns
cp /opt/virtualXS/files/rpm/* $RPM_BUILD_ROOT/opt/virtualXS/files/rpm
cp /opt/virtualXS/files/ssh/* $RPM_BUILD_ROOT/opt/virtualXS/files/ssh
cp /opt/virtualXS/files/vsftpd/* $RPM_BUILD_ROOT/opt/virtualXS/files/vsftpd
cp /opt/virtualXS/lib/* $RPM_BUILD_ROOT/opt/virtualXS/lib
cp /opt/virtualXS/gui/* $RPM_BUILD_ROOT/opt/virtualXS/gui
cp /opt/virtualXS/sources/* $RPM_BUILD_ROOT/opt/virtualXS/sources

exit

%files
#/usr/bin/hello-world.sh
%attr(0700, root, root) /opt/virtualXS/vxs
%attr(0644, root, root) /opt/virtualXS/files/*
%attr(0644, root, root) /opt/virtualXS/lib/*
%attr(0644, root, root) /opt/virtualXS/gui/*
%attr(0777, root, root) /opt/virtualXS/gui/gui.js
%attr(0644, root, root) /opt/virtualXS/sources/*
%attr(0700, root, root) /opt/virtualXS/sources/git.sh


%build

#cat > hello-world.sh <<EOF
##!/usr/bin/bash
#echo Hello Nick 008
#EOF

cp /opt/virtualXS/vxs /root/rpmbuild/BUILD/


%install
mkdir -p %{buildroot}/usr/bin/

mkdir -p %{buildroot}/opt/virtualXS
mkdir -p %{buildroot}/opt/virtualXS/files
mkdir -p %{buildroot}/opt/virtualXS/files/backup
mkdir -p %{buildroot}/opt/virtualXS/files/bitworker
mkdir -p %{buildroot}/opt/virtualXS/files/certbot
mkdir -p %{buildroot}/opt/virtualXS/files/dovecot
mkdir -p %{buildroot}/opt/virtualXS/files/firewall
mkdir -p %{buildroot}/opt/virtualXS/files/httpd
mkdir -p %{buildroot}/opt/virtualXS/files/mysql
mkdir -p %{buildroot}/opt/virtualXS/files/postfix
mkdir -p %{buildroot}/opt/virtualXS/files/powerdns
mkdir -p %{buildroot}/opt/virtualXS/files/rpm
mkdir -p %{buildroot}/opt/virtualXS/files/ssh
mkdir -p %{buildroot}/opt/virtualXS/files/vsftpd
mkdir -p %{buildroot}/opt/virtualXS/lib
mkdir -p %{buildroot}/opt/virtualXS/gui
mkdir -p %{buildroot}/opt/virtualXS/sources

cp /opt/virtualXS/vxs %{buildroot}/opt/virtualXS
cp /opt/virtualXS/files/backup/* %{buildroot}/opt/virtualXS/files/backup
cp /opt/virtualXS/files/bitworker/* %{buildroot}/opt/virtualXS/files/bitworker
cp /opt/virtualXS/files/certbot/* %{buildroot}/opt/virtualXS/files/certbot
cp /opt/virtualXS/files/dovecot/* %{buildroot}/opt/virtualXS/files/dovecot
cp /opt/virtualXS/files/firewall/* %{buildroot}/opt/virtualXS/files/firewall
cp /opt/virtualXS/files/httpd/* %{buildroot}/opt/virtualXS/files/httpd
cp /opt/virtualXS/files/mysql/* %{buildroot}/opt/virtualXS/files/mysql
cp /opt/virtualXS/files/postfix/* %{buildroot}/opt/virtualXS/files/postfix
cp /opt/virtualXS/files/powerdns/* %{buildroot}/opt/virtualXS/files/powerdns
cp /opt/virtualXS/files/rpm/* %{buildroot}/opt/virtualXS/files/rpm
cp /opt/virtualXS/files/ssh/* %{buildroot}/opt/virtualXS/files/ssh
cp /opt/virtualXS/files/vsftpd/* %{buildroot}/opt/virtualXS/files/vsftpd
cp /opt/virtualXS/lib/* %{buildroot}/opt/virtualXS/lib
cp /opt/virtualXS/gui/* %{buildroot}/opt/virtualXS/gui
cp /opt/virtualXS/sources/* %{buildroot}/opt/virtualXS/sources




#install -m 755 hello-world.sh %{buildroot}/usr/bin/hello-world.sh
install -m 755 vxs %{buildroot}/opt/virtualXS/vxs



%pre




%post
################################################################################
# Post Installation stuff                                                      #
################################################################################
###create symlink
if [ ! -e /bin/vxs ]
then
   ln -s /opt/virtualXS/vxs /bin/vxs
fi

if [ -e /usr/share/applications ]
then
   cp /opt/virtualXS/gui/virtualXS.desktop /usr/share/applications/
fi

################################################################################
# Uninstall Installation stuff                                                 #
################################################################################
%postun

###if [ -e /opt/virtualXS ]
###then
###   rm -rf /opt/virtualXS
###fi

###if [ -e /usr/local/bin/vxs ]
###then
###   rm -f /usr/local/bin/vxs
###fi


%clean
rm -rf %{buildroot}



%changelog
* Fri Apr 30 2021 BitWorker Reverse Engineering
- Bugfix and trial version
- Rebuild the virtualXS SPEC file

