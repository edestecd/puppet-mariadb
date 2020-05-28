# params.pp
# Set up MariaDB Cluster parameters defaults etc.
#

class mariadb::params {
  include 'mysql::params'

  # ### init vars ####
  $manage_user     = false
  $manage_timezone = false
  $manage_repo     = true
  $repo_version    = '10.1'
  $auth_pam        = true
  $auth_pam_plugin = 'auth_pam.so'

  $service_name = $::service_provider ? {
    'systemd' => 'mariadb',
    default   => 'mysql',
  }

  # wsrep patch config
  $wsrep_cluster_address = undef
  $wsrep_cluster_peers   = undef
  $wsrep_cluster_port    = '4567'
  $wsrep_cluster_name    = undef
  $wsrep_sst_user        = 'wsrep_sst'
  $wsrep_sst_user_peers  = '%'
  $wsrep_sst_password    = 'UNSET' # lint:ignore:security_password_in_code
  $wsrep_sst_method      = 'mysqldump'
  $root_password         = 'UNSET' # lint:ignore:security_password_in_code

  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease, '6.0') >= 0) {
    # client.pp
    $client_package_name = 'MariaDB-client'
    $shared_package_name = 'MariaDB-shared'
    $devel_package_name  = 'MariaDB-devel'

    # user.pp
    $user      = 'mysql'
    $comment   = 'MySQL server'
    $uid       = 494
    $gid       = 494
    $home      = '/var/lib/mysql'
    $backupdir = '/var/lib/mysqlbackups'
    $shell     = '/sbin/nologin'
    $group     = 'mysql'
    $groups    = undef

    # config.pp
    $log_error      = '/var/lib/mysql/mysqld.log'
    $config_file    = '/etc/my.cnf.d/server.cnf'
    $includedir     = '' # lint:ignore:empty_string_assignment
    $config_dir     = '/etc/my.cnf.d'
    $pidfile        = '/var/lib/mysql/mysqld.pid'
    $wsrep_provider = '/usr/lib64/galera/libgalera_smm.so'

    # server.pp
    $server_package_name = 'MariaDB-server'

    # cluster.pp
    $cluster_package_name = 'MariaDB-Galera-server'

    # backup
    $backup_package_name = 'MariaDB-backup'
  } elsif ($::osfamily == 'Debian') and (
    (($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '7.0') >= 0)) or
    (($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '12.0') >= 0))
  ) {
    # client.pp
    $client_package_name = 'mariadb-client'
    $shared_package_name = undef
    $devel_package_name  = 'libmariadbd-dev'

    # user.pp
    $user      = 'mysql'
    $comment   = 'MySQL Server'
    $uid       = 494
    $gid       = 494
    $home      = '/var/lib/mysql'
    $backupdir = '/var/lib/mysqlbackups'
    $shell     = '/bin/false'
    $group     = 'mysql'
    $groups    = undef

    # config.pp
    $log_error      = undef
    $config_file    = '/etc/mysql/my.cnf'
    $includedir     = '/etc/mysql/conf.d'
    $config_dir     = '/etc/mysql/conf.d'
    $pidfile        = '/var/run/mysqld/mysqld.pid'
    $wsrep_provider = '/usr/lib/galera/libgalera_smm.so'

    # server.pp
    $server_package_name = 'mariadb-server'

    # cluster.pp
    $cluster_package_name = 'mariadb-galera-server'

    # backup
    $backup_package_name = 'mariadb-backup'
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

  $client_default_options = {
    'client' => {
      'port' => '3306',
    },
    'mysqldump' => {
      'max_allowed_packet' => '16M',
      'quick'              => true,
      'quote-names'        => true,
    },
  }

  $server_default_options = {
    'mysqld_safe' => {
      'log-error' => $log_error,
    },
    'mysqld' => {
      'log-error'             => $log_error,
      'pid-file'              => $pidfile,
      'innodb_file_per_table' => 'ON',
    },
  }

  $cluster_default_options = {
    'mysqld_safe' => {
      'log-error' => $log_error,
    },
    'mysqld' => {
      'bind-address'          => '0.0.0.0',
      'performance_schema'    => 'ON',
      'log-error'             => $log_error,
      'pid-file'              => $pidfile,
      'query_cache_limit'     => undef,
      'query_cache_size'      => undef,
      'innodb_file_per_table' => 'ON',
    },
  }

  $galera_default_options = {
    'mysqld' => {
      'wsrep_on'                        => 'ON',
      'wsrep_provider'                  => $wsrep_provider,
      'wsrep_node_name'                 => $::hostname,
      'wsrep_slave_threads'             => '1', # $::processorcount * 2
      'wsrep_node_address'              => $::ipaddress,
      'wsrep_node_incoming_address'     => $::ipaddress,
      'binlog_format'                   => 'ROW',
      'default_storage_engine'          => 'InnoDB',
      'innodb_autoinc_lock_mode'        => '2',
      'innodb_doublewrite'              => '1',
      'query_cache_size'                => '0',
      'innodb_flush_log_at_trx_commit'  => '2',
      '#innodb_locks_unsafe_for_binlog' => '1',
    },
  }
}
