# mysql.pp
# Manage the puppetlabs mysql module.
#

class mariadb::server::mysql (
  Boolean $cluster = false,
){

  if $mariadb::server::auth_pam {
    $auth_pam_options = { 'mysqld' => { 'plugin-load' => $mariadb::server::auth_pam_plugin } }
  } else {
    $auth_pam_options = {}
  }

  $options = $cluster ? {
    false => $mariadb::server::options,
    true  => $mariadb::cluster::cluster_options,
  }

  # https://mariadb.com/kb/en/mariadb/yum/#installing-mariadb-galera-cluster-with-yum
  # Galera Cluster is included in the default MariaDB packages from 10.1,
  if !$cluster or (versioncmp($mariadb::server::repo_version, '10.1') >= 0) {
    $package_name = $mariadb::params::server_package_name
  } else {
    $package_name = $mariadb::params::cluster_package_name
  }

  class { 'mysql::server':
    config_file             => $mariadb::server::config_file,
    includedir              => $mariadb::server::includedir,
    override_options        => mysql::normalise_and_deepmerge($auth_pam_options, $options),
    package_ensure          => installed,
    package_name            => $package_name,
    remove_default_accounts => true,
    restart                 => $mariadb::server::restart,
    root_password           => $mariadb::server::root_password,
    service_enabled         => $mariadb::server::service_enabled,
    service_manage          => $mariadb::server::service_manage,
    service_name            => $mariadb::server::service_name,
    users                   => $mariadb::server::users,
    grants                  => $mariadb::server::grants,
    databases               => $mariadb::server::databases,
  }

  anchor { 'mariadb::server::mysql::start': }
  -> Class['::mysql::server']
  -> anchor { 'mariadb::server::mysql::end': }
}
