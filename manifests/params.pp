# params.pp
# Set up MariaDB Cluster parameters defaults etc.
#

class mariadb::params {
  include '::mysql::params'

  #### init vars ####
  $manage_user     = false
  $manage_timezone = false
  $manage_repo     = true
  $repo_version    = '10.1'
  $auth_pam        = true
  $auth_pam_plugin = 'auth_pam.so'

  if ($::osfamily == 'RedHat') and (versioncmp($::operatingsystemrelease, '6.0') >= 0) {
    #### client specific vars ####
    # client.pp
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

    #### cluster specific vars ####
    # user.pp
    $user    = 'mysql'
    $comment = 'MySQL server'
    $uid     = 494
    $gid     = 494
    $home    = '/var/lib/mysql'
    $shell   = '/sbin/nologin'
    $group   = 'mysql'
    $groups  = undef

    # config.pp
    $config_file                 = '/etc/my.cnf.d/server.cnf'
    $includedir                  = '' # lint:ignore:empty_string_assignment
    $config_dir                  = '/etc/my.cnf.d'
    # wsrep patch config
    $wsrep_provider              = '/usr/lib64/galera/libgalera_smm.so'
    $wsrep_cluster_address       = undef
    $wsrep_cluster_peers         = undef
    $wsrep_cluster_name          = undef
    $wsrep_sst_user              = 'wsrep_sst'
    $wsrep_sst_password          = 'UNSET'
    $wsrep_sst_method            = 'mysqldump'
    $wsrep_slave_threads         = '1' #$::processorcount * 2
    $wsrep_node_address          = $::ipaddress
    $wsrep_node_incoming_address = $::ipaddress
    $root_password               = 'UNSET'

    # mysql.pp
    $cluster_default_options = {
      'mysqld' => {
        'bind-address'          => '0.0.0.0',
        'performance_schema'    => 'ON',
        'query_cache_limit'     => undef,
        'query_cache_size'      => undef,
        'innodb_file_per_table' => 'ON',
      },
    }
  } elsif ($::osfamily == 'Debian') and (
    (($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '7.0') >= 0)) or
    (($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '12.0') >= 0))
  ) {
    # stub!
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }
}
