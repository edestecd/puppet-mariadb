# mysql.pp
# Manage the puppetlabs mysql module.
#

class mariadb::client::mysql (
  $dev = $mariadb::client::dev,
){

  class { '::mysql::client':
    package_ensure => installed,
    package_name   => 'MariaDB-client',
  }

  if $dev {
    class { '::mysql::bindings':
      client_dev                => true,
      client_dev_package_ensure => installed,
      client_dev_package_name   => 'MariaDB-shared',
      daemon_dev                => true,
      daemon_dev_package_ensure => installed,
      daemon_dev_package_name   => 'MariaDB-devel',
    }

    Class['::mysql::client'] ->
    Class['::mysql::bindings'] ->
    Anchor['mariadb::client::mysql::end']
  }

  anchor { 'mariadb::client::mysql::start': } ->
  Class['::mysql::client'] ->
  anchor { 'mariadb::client::mysql::end': }
}
