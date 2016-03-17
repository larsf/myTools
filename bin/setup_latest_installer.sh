#!/bin/bash

INSTALLER_URL_RH=http://yum.qa.lab/installer-master-ui/
INSTALLER_URL_DEB=http://apt.qa.lab/installer-master-ui/
CORE_URL_RH=http://yum.qa.lab/v5.1.0/
#CORE_URL_RH=http://yum.qa.lab/redhat/
CORE_URL_DEB=http://apt.qa.lab/v5.1.0/
ECOS_URL_RH=http://yum.qa.lab/opensource
ECOS_URL_DEB=http://apt.qa.lab/opensource


OS=$( lsb_release -si )
case "$OS" in
    CentOS|RedHat|Fedora)
         INSTALLER_URL="$INSTALLER_URL_RH"
         CORE_URL="$CORE_URL_RH"
         ECOS_URL="$ECOS_URL_RH"
    ;;
    Ubuntu|Debian)
         INSTALLER_URL="$INSTALLER_URL_DEB"
         CORE_URL="$CORE_URL_DEB"
         ECOS_URL="$ECOS_URL_DEB"
    ;;
esac

rm -f /tmp/mapr-setup.sh
cd /tmp; 
wget $INSTALLER_URL/mapr-setup.sh
if [ $? -eq 0 ] ; then
    bash  /tmp/mapr-setup.sh -y remove 
    bash  /tmp/mapr-setup.sh -u $INSTALLER_URL $CORE_URL $ECOS_URL
fi
