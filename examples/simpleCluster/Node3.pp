#Setup a Mariadbcluster with 3 Nodes

node 'localcluster3.localdomain' {
  class {
    'apt':
  }
  class { 'mariadb::cluster' :
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
  }
