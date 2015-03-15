# CDH Cluster With Cloudera Manager

You can setup Hadoop Cluster(CDH) with Cloudera Manager 5 on VirtualBox quickly.

## Setup

At first, please download and install ChefDK from the following site.

```
https://downloads.chef.io/chef-dk/
```

Next, install some vagrant plugins and boot virtual machines with vagrant.

```
$ vagrant plugin install vagrant-hostmanager vagrant-omnibus vagrant-berkshelf
$ vagrant up
```

## Cluster

A master node and three slave nodes will run.

### OS

CentOS 6.5 x86_64

### Memory

Master nodes have 4G, slave nodes have 2G.

### HostName

```
master: hadoop11
slave : hadoop1[1-3]
```

### Network

```
master: 192.168.10.101
slave : 192.168.10.20[1-3]
```

## Fluentd

```
$ bundle install --path=vendor/bundle
$ bundle exec rake fluent:start
```

### Emit Log

Execute the following command, then you will see data at `/tmp/access_log` on HDFS in a few minutes.

```
$ bundle exec rake fluent:cat
```

### WebHDFS Append Enabled

To allow to append to a file by fluend, you need to add the following setting to `hdfs-site.xml` safety valve.

```
<property>
  <name>dfs.support.append</name>
  <value>true</value>
</property>

<property>
  <name>dfs.support.broken.append</name>
  <value>true</value>
</property>
```

## Hive and Impala

You can create a table in the default database by executing `/vagrant/scripts/create-table-accesslog.sh`

```
$ /vagrant/scripts/create-table-accesslog.sh
```

### Run Query

If you install Hive and Impala with Cloudera Manager, you can run the following query;

**Hive**

```
$ sudo -u hive hive -e "select agent, count(*) from access_log group by agent;"
```

**Impala**

```
$ impala-shell -i hadoop21 -q "invalidate metadata access_log;select agent, count(*) from access_log group by agent;"
```