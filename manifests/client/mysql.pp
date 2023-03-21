# mysql.pp
# Manage the puppetlabs mysql module.
#

class mariadb::client::mysql (
  $dev = $mariadb::client::dev,
){

  class { 'mysql::client':
    package_ensure => present,
    package_name   => $mariadb::params::client_package_name,
  }

  if $dev {
    class { 'mysql::bindings':
      client_dev                => true,
      client_dev_package_ensure => present,
      client_dev_package_name   => $mariadb::params::devel_package_name,
      daemon_dev                => true,
      daemon_dev_package_ensure => present,
      daemon_dev_package_name   => $mariadb::params::shared_package_name,
    }

    Class['mysql::client']
    -> Class['mysql::bindings']
    -> Anchor['mariadb::client::mysql::end']
  }

  anchor { 'mariadb::client::mysql::start': }
  -> Class['mysql::client']
  -> anchor { 'mariadb::client::mysql::end': }
}
