# Changelog

All notable changes to this project will be documented in this file.

## 2020-08-26 (2.1.1)  Brad Koby
* Update PDK template version
* Increase stdlib dependency max version
* Increase puppet max version

## 2020-08-19 (2.1.0)  Brad Koby
* Use renamed 'deepmerge' function 'normalise_and_deepmerge'
* requires puppetlabs/mysql 9.0.0

## 2020-03-06 (2.0.1)  Brad Koby
* Stop using absolute class names
* Bump puppetlabs-apt max version
* Limit puppet puppetlabs-mysql max version (due to mysql::deepmerge removal)
* Convert PDK template to version 1.9.0
* Set mock_with to :rspec

## 2018-10-31 (2.0.0)  Chris Edester
* Use puppet 4 compatible functions - thanks Tobias Urdin
* requires puppetlabs/mysql 6.0.0

## 2018-07-26 (1.1.1)  Brad Koby
* Ensure 'socat' package is installed when using mariabackup sst method

## 2018-07-25 (1.1.0)  Brad Koby
* Support mariabackup wsrep_sst_method
* Add mariabackup class to do incremental/daily backups
* PDK 1.6.0

## 2018-07-09 (1.0.2)  Brad Koby
* Fix bug: Pass repo_version to mariadb::server from mariadb::cluster

## 2018-06-05 (1.0.1)  Brad Koby
* Works with mysql::backup::xtrabackup

## 2018-04-24 (1.0.0)  Chris Edester
* README updates
* Create one wsrep_sst_user per peer
* socat dependency handled for xtrabackup
* wsrep_sst_user tls_options
* compatability with newer mysql module
* PDK support
* Puppet 4/5 support
* Drop Puppet 3 support
* Add safe cluster mysqldump backup with garbd

## 2016-09-15 (0.6.0)  Chris Edester
* Fix Unknown system variable on fact resolution
* Detect service name based on service_provider

## 2016-09-08 (0.5.0)  Chris Edester
* Initial working version with support for Debian, RedHat
* Supports Client, Server, Cluster, Repo

## 2016-08-29 (0.0.1)  Chris Edester
* Initial Import from Dragonfly project
