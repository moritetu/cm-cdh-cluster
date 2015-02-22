# CDH Cluster With Cloudera Manager

You can setup Hadoop Cluster(CDH) with Cloudera Manager 5 on VirtualBox quickly.

## Setup

```
$ vagrant plugin install vagrant-hostmanager
$ vagrant up
```

### Cluster

Two master nodes and three slave nodes will run.

#### OS

CentOS 6.5 x86_64

#### Memory

Master nodes have 4G, slave nodes have 2G.

#### HostName

```
master: hadoop1[1-2]
slave : hadoop1[1-3]
```

#### Network

```
master: 192.168.10.10[1-2]
slave : 192.168.10.20[1-3]
```

### Fluentd

```
$ bundle install --path=vendor/bundle
$ bundle exec rake fluent:start
```

#### Emit Log

Execute the following command, then you will see data at `/tmp/access_log` on HDFS in a few minutes.

```
$ bundle exec rake fluent:cat
```

#### WebHDFS Append Enabled

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

### Hive

You can create a table in the default database by executing `/vagrant/scripts/create-table-accesslog.sh`

```
$ /vagrant/scripts/create-table-accesslog.sh
```

#### Run Query

```
$ sudo -u hive hive -e "
SELECT log.agent, count(*) FROM access_log
  LATERAL VIEW json_tuple(
    access_log.message,
    'host',
    'path',
    'agent'
  ) log as host, path, agent
GROUP BY log.agent;
"
```
