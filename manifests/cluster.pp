# cluster.pp
# MariaDB Galera Cluster
# Server application
#
#
# Uses puppetlabs/mysql Module
#   https://github.com/puppetlabs/puppetlabs-mysql
#
# With insights from NeCTAR-RC/mariadb Module
#   https://github.com/NeCTAR-RC/puppet-mariadb
#
# http://dev.mysql.com/doc/refman/5.6/en/adding-users.html
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/mariadb-plugins/pam-authentication-plugin
#
# PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
# To do so, start the server, then issue the following commands:
#
# /usr/bin/mysqladmin -u root password 'new-password'
# /usr/bin/mysqladmin -u root -h mualdrytxx.mcs.miamioh.edu password 'new-password'
#
# Alternatively you can run:
# /usr/bin/mysql_secure_installation
#
# which will also give you the option of removing the test
# databases and anonymous user created by default.  This is
# strongly recommended for production servers.
#
#
# To initialize default mysql db (as root):
#   mysql_install_db --no-defaults --datadir=/srv/mysql_cluster/mysqld_data/
#   mysql_install_db --user=mysql --datadir=/srv/mysql_cluster/mysqld_data
#   THEN
#   ln -s /srv/mysql_cluster/tmp/sockets/mysqld.sock /var/lib/mysql/mysql.sock
#   mysql_secure_installation
#   rm /var/lib/mysql/mysql.sock
#
#

class mariadb::cluster (
  $manage_user                 = $mariadb::params::manage_user,
  $manage_timezone             = $mariadb::params::manage_timezone,
  $manage_repo                 = $mariadb::params::manage_repo,
  $repo_version                = $mariadb::params::repo_version,
  $dev                         = true,
  $restart                     = false,
  $service_enabled             = true,
  $service_manage              = true,

  $user                        = $mariadb::params::user,
  $comment                     = $mariadb::params::comment,
  $uid                         = $mariadb::params::uid,
  $gid                         = $mariadb::params::gid,
  $home                        = $mariadb::params::home,
  $shell                       = $mariadb::params::shell,
  $group                       = $mariadb::params::group,
  $groups                      = $mariadb::params::groups,

  $config_file                 = $mariadb::params::config_file,
  $includedir                  = $mariadb::params::includedir,
  $config_dir                  = $mariadb::params::config_dir,
  $wsrep_provider              = $mariadb::params::wsrep_provider,
  $wsrep_cluster_address       = $mariadb::params::wsrep_cluster_address,
  $wsrep_cluster_peers         = $mariadb::params::wsrep_cluster_peers,
  $wsrep_cluster_name          = $mariadb::params::wsrep_cluster_name,
  $wsrep_sst_user              = $mariadb::params::wsrep_sst_user,
  $wsrep_sst_password          = $mariadb::params::wsrep_sst_password,
  $wsrep_sst_method            = $mariadb::params::wsrep_sst_method,
  $wsrep_slave_threads         = $mariadb::params::wsrep_slave_threads,
  $wsrep_node_address          = $mariadb::params::wsrep_node_address,
  $wsrep_node_incoming_address = $mariadb::params::wsrep_node_incoming_address,
  $root_password               = $mariadb::params::root_password,
  $override_options            = {},

  $auth_pam                    = $mariadb::params::auth_pam,
  $auth_pam_plugin             = $mariadb::params::auth_pam_plugin,
  $storeconfigs_enabled        = false,

  $users                       = {},
  $grants                      = {},
  $databases                   = {},
) inherits mariadb::params {

  validate_bool($manage_user, $manage_repo, $dev)

  $options = mysql_deepmerge($mariadb::params::cluster_default_options, $override_options)

  if $manage_repo {
    class { '::mariadb::repo':
      repo_version => $repo_version,
      percona_repo => ($wsrep_sst_method in ['xtrabackup', 'xtrabackup-v2']),
    }
  }

  if $manage_user {
    Anchor['mariadb::cluster::start'] ->
    class { '::mariadb::cluster::user': } ->
    Class['mariadb::client::mysql']
  }

  if $manage_timezone {
    Class['mariadb::cluster::galera_config'] ->
    class { '::mariadb::cluster::timezone': } ->
    Anchor['mariadb::cluster::end']
  }

  anchor { 'mariadb::cluster::start': } ->
  class { '::mariadb::client::mysql': dev => $dev } ->
  class { '::mariadb::cluster::mysql': } ->
  class { '::mariadb::cluster::auth': } ->
  class { '::mariadb::cluster::galera_config': } ->
  anchor { 'mariadb::cluster::end': }

  if $::settings::storeconfigs and $storeconfigs_enabled {
    Mysql::Db <<| tag == $::domain |>> {
      require => Anchor['mariadb::cluster::end'],
    } ->
    Mariadb::Db_grant <<| tag == $::domain |>> {
      require => Anchor['mariadb::cluster::end'],
    }
  }
}
