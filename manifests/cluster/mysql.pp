# mysql.pp
# Manage the puppetlabs mysql module.
#

class mariadb::cluster::mysql {

  validate_bool($mariadb::cluster::auth_pam)
  validate_string($mariadb::cluster::auth_pam_plugin)

  validate_string($mariadb::cluster::root_password)

  if $mariadb::cluster::auth_pam {
    $auth_pam_options = {'mysqld' => {'plugin-load' => $mariadb::cluster::auth_pam_plugin}}
  } else {
    $auth_pam_options = {}
  }

  if $mariadb::cluster::wsrep_sst_method in ['xtrabackup', 'xtrabackup-v2'] {
    package { 'percona-xtrabackup':
      ensure => installed,
      before => Class['::mysql::server'],
    }
  }

  # https://mariadb.com/kb/en/mariadb/yum/#installing-mariadb-galera-cluster-with-yum
  # Galera Cluster is included in the default MariaDB packages from 10.1,
  if versioncmp($mariadb::cluster::repo_version, '10.1') >= 0 {
    $_cluster_package_name = $mariadb::params::server_package_name
  } else {
    $_cluster_package_name = $mariadb::params::cluster_package_name
  }

  class { '::mysql::server':
    config_file             => $mariadb::cluster::config_file,
    includedir              => $mariadb::cluster::includedir,
    override_options        => mysql_deepmerge($auth_pam_options, $mariadb::cluster::cluster_options),
    package_ensure          => installed,
    package_name            => $_cluster_package_name,
    remove_default_accounts => true,
    restart                 => $mariadb::cluster::restart,
    root_password           => $mariadb::cluster::root_password,
    service_enabled         => $mariadb::cluster::service_enabled,
    service_manage          => $mariadb::cluster::service_manage,
    service_name            => 'mysql',
    users                   => $mariadb::cluster::users,
    grants                  => $mariadb::cluster::grants,
    databases               => $mariadb::cluster::databases,
  }

  anchor { 'mariadb::cluster::mysql::start': } ->
  Class['::mysql::server'] ->
  anchor { 'mariadb::cluster::mysql::end': }
}
