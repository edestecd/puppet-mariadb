# Sample Usage:
#   mariadb::database { "dbname" :
#       $host = 'localhost', 
#       $ensure = 'present',
#       $charset = 'utf8', 
#       $collate = 'utf8_general_ci'
#   }
define mariadb::database($host = 'localhost', $ensure = 'present', $charset = 'utf8', $collate = 'utf8_general_ci' ) {
  include '::mysql::client'

  $dbname = name
  $db_resource = {
    ensure => $ensure,
    charset => $charset,
    collate => $collate,
    provider => 'mysql',
    require => [Class['mysql::server'], Class['mysql::client']],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

}