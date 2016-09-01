# galera_config.pp
# Manage galera cluster specific config.
#
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/replication-cluster-multi-master/galera/getting-started-with-mariadb-galera-cluster
# https://mariadb.com/kb/en/mariadb/mariadb-documentation/replication-cluster-multi-master/galera/galera-cluster-system-variables
# http://tecadmin.net/setup-mariadb-galera-cluster-5-5-in-centos-rhel
# http://galeracluster.com/documentation-webpages/configuration.html
#
#

class mariadb::cluster::galera_config {

  validate_absolute_path($mariadb::cluster::config_dir)

  validate_absolute_path($mariadb::cluster::wsrep_provider)
  validate_string($mariadb::cluster::wsrep_cluster_name)
  validate_string($mariadb::cluster::wsrep_sst_user)
  validate_string($mariadb::cluster::wsrep_sst_password)
  validate_re($mariadb::cluster::wsrep_sst_method, '^(mysqldump|rsync|xtrabackup|xtrabackup-v2)$')
  validate_re($mariadb::cluster::wsrep_slave_threads, '^\d+$')
  validate_string($mariadb::cluster::wsrep_node_address)
  validate_string($mariadb::cluster::wsrep_node_incoming_address)

  if $mariadb::cluster::wsrep_cluster_address {
    $_wsrep_cluster_address = $mariadb::cluster::wsrep_cluster_address
  } elsif is_array($mariadb::cluster::wsrep_cluster_peers) {
    $_wsrep_cluster_peers = join($mariadb::cluster::wsrep_cluster_peers, ',')
    $_wsrep_cluster_address = "'gcomm://${_wsrep_cluster_peers}'"
  } else {
    fail("${module_name} - you must set either wsrep_cluster_address or wsrep_cluster_peers")
  }

  $options = {
    'mysqld' => {
      'wsrep_provider'                  => $mariadb::cluster::wsrep_provider,
      'wsrep_cluster_address'           => $_wsrep_cluster_address,
      'wsrep_cluster_name'              => $mariadb::cluster::wsrep_cluster_name,
      'wsrep_sst_auth'                  => "'${mariadb::cluster::wsrep_sst_user}:${mariadb::cluster::wsrep_sst_password}'",
      'wsrep_sst_method'                => $mariadb::cluster::wsrep_sst_method,
      'wsrep_slave_threads'             => $mariadb::cluster::wsrep_slave_threads,
      'wsrep_node_address'              => $mariadb::cluster::wsrep_node_address,
      'wsrep_node_incoming_address'     => $mariadb::cluster::wsrep_node_incoming_address,
      'binlog_format'                   => 'ROW',
      'default_storage_engine'          => 'InnoDB',
      'innodb_autoinc_lock_mode'        => '2',
      'innodb_doublewrite'              => '1',
      'query_cache_size'                => '0',
      'innodb_flush_log_at_trx_commit'  => '2',
      '#innodb_locks_unsafe_for_binlog' => '1',
    },
  }
  $includedir = false

  file { "${mariadb::cluster::config_dir}/cluster.cnf":
    ensure  => file,
    owner   => 'root',
    group   => $mysql::params::root_group,
    mode    => '0644',
    content => template('mysql/my.cnf.erb'),
  }
}
