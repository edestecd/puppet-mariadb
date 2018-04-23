# config.pp
# Manage client custom config.
#
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/replication-cluster-multi-master/galera/getting-started-with-mariadb-galera-cluster
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/replication-cluster-multi-master/galera/galera-cluster-system-variables
# http://tecadmin.net/setup-mariadb-galera-cluster-5-5-in-centos-rhel
# http://galeracluster.com/documentation-webpages/configuration.html
#
# my.cnf examples:
#   /usr/share/mysql/my-huge.cnf
#   /usr/share/mysql/my-innodb-heavy-4G.cnf
#   /usr/share/mysql/my-large.cnf
#   /usr/share/mysql/my-medium.cnf
#   /usr/share/mysql/my-small.cnf
#
#

class mariadb::client::config {

  $options = $mariadb::client::options
  $includedir = false

  file { "${mariadb::client::config_dir}/client.cnf":
    ensure  => file,
    owner   => 'root',
    group   => $mysql::params::root_group,
    mode    => '0644',
    content => template('mysql/my.cnf.erb'),
  }
}
