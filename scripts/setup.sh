#!/usr/bin/env bash

# Mount a new fdd
HDD_FORMAT=ext4
HDD_SDB_DEVICE=/dev/sdb
HDD_SDB_PARTITION=${HDD_SDB_DEVICE}1
MOUNT_POINT=/data

# Update package
yum clean all
yum update -y
yum install -y parted wget

# Init disk
parted --script $HDD_SDB_DEVICE 'mklabel gpt'
parted --script $HDD_SDB_DEVICE 'mkpart primary 0 -0'
/sbin/mkfs.${HDD_FORMAT} ${HDD_SDB_PARTITION}
mkdir $MOUNT_POINT
mount -t $HDD_FORMAT -o defaults ${HDD_SDB_PARTITION} $MOUNT_POINT

echo "$HDD_SDB_PARTITION $MOUNT_POINT $HDD_FORMAT defaults 1 2" >> /etc/fstab

# Init /etc/hosts
cat <<EOF > /etc/hosts
127.0.0.1    localhost
EOF

# Create a symlink to /opt/cloudera
mkdir -p $MOUNT_POINT/cloudera
ln -s $MOUNT_POINT/cloudera /opt/cloudera

# Change kernel parameters
echo 0 > /proc/sys/vm/swappiness
cat <<EOF >> /etc/sysctl.conf
vm.swappiness = 0
EOF

# Add user vagrant to group wheel
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
