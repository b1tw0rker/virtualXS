#!/bin/bash

### Variables
###
###
SPEC=/root/rpmbuild/SPECS/virtualXS.spec
vxs=/opt/virtualXS/vxs
repo_url=srv002.bit-worker.com

### get old Version
### 
###
while read LINE
do

if [[ "$LINE" =~ "Version:" ]]; then
 IN=$LINE
 arrIN=(${IN//\ / })
 OLDVERSION=${arrIN[1]}    
 #echo $OLDVERSION
fi
done < $SPEC


### build new version
###
###
OLD=$OLDVERSION
arrIN=(${OLD//\./ })
let PATCHLEVEL=${arrIN[2]} 
let NEWPATCHLEVEL=$PATCHLEVEL+1


### ask me
### 
###
read -p "Old Version: " -ei $OLDVERSION u_version_old
read -p "New Version: " -ei 1.0.$NEWPATCHLEVEL u_version


### passe SPECS und vxs an
###
###
sed -i 's/^Version: '"$u_version_old"'/Version: '"$u_version"'/' $SPEC
sed -i 's/^### Version: '"$u_version_old"'/### Version: '"$u_version"'/' $vxs

### baue RPM
###
###
rpmbuild --target noarch -bb $SPEC


###########################################################################################

### sign rpm
###
###
rpmsign --addsign /root/rpmbuild/RPMS/noarch/virtualXS-$u_version-1.noarch.rpm



### transfer rpm to server
###
###
scp /root/rpmbuild/RPMS/noarch/virtualXS-$u_version-1.noarch.rpm root@$repo_url:/home/httpd/www.bit-worker.com/htdocs/repository/


### Updta repo on target machine
###
###
ssh root@$repo_url createrepo --update /home/httpd/www.bit-worker.com/htdocs/repository/



### Update github
###
###
/opt/virtualXS/sources/git.sh


exit 0
