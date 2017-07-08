# Sample Usage:
#   mariadb::user { 'foo' :
#       password => 'pw',
#       privileges => ['all'],
#       host => 'localhost',
#   }
define mariadb::utility::user($password, $host = 'localhost') {
  include '::mysql::client'

  $username = name
  $user_resource = {
    ensure => 'present',
    password_hash => mysql_password($password),
    provider => 'mysql',
    require => Class['::mysql::server'],
  }
  ensure_resource('mysql_user', "${username}@${host}", $user_resource)
}