#!/usr/bin/env bash

# Create a repo file
CLOUDERA_MANAGER_VER=${CLOUDERA_MANAGER_VER:-"5"}
cat <<EOF > /etc/yum.repos.d/cloudera-manager.repo
[cloudera-manager]
name = Cloudera Manager
baseurl = http://archive.cloudera.com/cm${CLOUDERA_MANAGER_VER}/redhat/\$releasever/\$basearch/cm/${CLOUDERA_MANAGER_VER}/
gpgkey = http://archive.cloudera.com/cm${CLOUDERA_MANAGER_VER}/redhat/\$releasever/\$basearch/cm/RPM-GPG-KEY-cloudera
gpgcheck = 1
EOF

rpm --import http://archive.cloudera.com/cm${CLOUDERA_MANAGER_VER}/redhat/$(cat /etc/redhat-release  | sed -E 's/CentOS release (.).*/\1/')/$(arch)/cm/RPM-GPG-KEY-cloudera

# Install cloudera manager packages
yum clean all
yum -y install oracle-j2sdk1.7 cloudera-manager-server cloudera-manager-daemons cloudera-manager-server-db-2
service cloudera-scm-server-db initdb
service cloudera-scm-server-db start
service cloudera-scm-server start
