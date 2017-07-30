mariadb
=============

[![Build Status](https://travis-ci.org/edestecd/puppet-mariadb.svg)](https://travis-ci.org/edestecd/puppet-mariadb)
[![Puppet Forge](https://img.shields.io/puppetforge/v/edestecd/mariadb.svg)](https://forge.puppetlabs.com/edestecd/mariadb)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/edestecd/mariadb.svg)](https://forge.puppetlabs.com/edestecd/mariadb)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/edestecd/mariadb.svg)](https://forge.puppetlabs.com/edestecd/mariadb/scores)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with mariadb](#setup)
    * [What mariadb affects](#what-mariadb-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mariadb](#beginning-with-mariadb)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors](#contributors)

## Overview

Puppet Module to install/configure MariaDB client/cluster/server

## Module Description

Uses the [puppetlabs/mysql](https://forge.puppet.com/puppetlabs/mysql) module to provide install/config/service/types/etc management.

This module basically manages the [official mariadb repo](https://downloads.mariadb.org/mariadb/repositories)
and wraps the mysql module with the correct params to switch to the maria packages.  

For the cluster, it also provides management of the wsrep mysql user and galera/wsrep specific config in a separate file.  

Also provided are wsrep var and status facts to monitor your cluster from your fav fact reporter ;)  

The mariadb module provides some classes to install and configure:
* MariaDB Client
* MariaDB Galera Cluster
* MariaDB Server
* MariaDB Repo

## Setup

### What mariadb affects

* mariadb package install
* mariadb config files
* mariadb services
* mariadb user/group (optional)

### Setup Requirements

only need to install the module

### Beginning with mariadb

Minimal mariadb client install for command line use:

```puppet
include mariadb::client
```

## Usage

### Manage the server with pam authentication

```puppet
class { 'mariadb::server':
  auth_pam => true,
}
```

### Also manage the server user and group

```puppet
class { 'mariadb::server':
  manage_user => true,
  uid         => 494,
  gid         => 494,
  shell       => '/sbin/nologin',
}
```

### Customize the cluster config

```puppet
class { 'mariadb::cluster':
  wsrep_cluster_peers     => delete(['192.168.1.1', '192.168.1.2', '192.168.1.3'], $::ipaddress),
  wsrep_cluster_name      => 'my_super_cluster',
  wsrep_sst_password      => 'super_secret_password',
  wsrep_sst_method        => 'xtrabackup-v2',
  root_password           => 'another_secret_password',
  override_options        => {
    'mysqld' => {
      'performance_schema'    => undef,
      'innodb_file_per_table' => 'OFF',
    },
  },
  galera_override_options => {
    'mysqld' => {
      'wsrep_slave_threads'            => '2',
      'innodb_flush_log_at_trx_commit' => '0',
    },
  }
}
```

### Configure with hiera yaml

```puppet
include mariadb::cluster
```
```yaml
---
mariadb::cluster::manage_timezone: true

mariadb::cluster::wsrep_cluster_peers:
- 192.168.1.1
- 192.168.1.2
mariadb::cluster::wsrep_cluster_name: my_super_cluster
mariadb::cluster::wsrep_sst_method: rsync
mariadb::cluster::root_password: another_secret_password

mariadb::cluster::override_options:
  mysqld:
    performance_schema: OFF
    innodb_file_per_table: OFF
mariadb::cluster::galera_override_options:
  mysqld:
    wsrep_slave_threads: 2
    innodb_flush_log_at_trx_commit: 0
```

## Reference

### Classes

* mariadb::client
* mariadb::cluster
* mariadb::server
* mariadb::repo

## Limitations

This module has been built on and tested against Puppet 3.8 and higher.  
While I am sure other versions work, I have not tested them.

This module supports modern RedHat and Debian based systems.  
No plans to support other versions (unless you add it :)..

## Development

Pull Requests welcome
