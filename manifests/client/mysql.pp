# mysql.pp
# Manage the puppetlabs mysql module.
#

class mariadb::client::mysql (
  $dev = $mariadb::client::dev,
){

  class { 'mysql::client':
    package_ensure => installed,
    package_name   => $mariadb::params::client_package_name,
  }

  if $dev {
    class { 'mysql::bindings':
      client_dev                => true,
      client_dev_package_ensure => installed,
      client_dev_package_name   => $mariadb::params::devel_package_name,
      daemon_dev                => $mariadb::params::shared_package_name,
      daemon_dev_package_ensure => installed,
      daemon_dev_package_name   => $mariadb::params::shared_package_name,
    }

    Class['::mysql::client']
    -> Class['::mysql::bindings']
    -> Anchor['mariadb::client::mysql::end']
  }

  anchor { 'mariadb::client::mysql::start': }
  -> Class['::mysql::client']
  -> anchor { 'mariadb::client::mysql::end': }
}
