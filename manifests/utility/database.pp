# Sample Usage:
#   mariadb::database { "dbname" :
#       host = 'localhost', 
#       dbname => 'dbname', 
#       ensure => 'present',
#       charset => 'utf8', 
#       collate => 'utf8_general_ci'
#   }
define mariadb::utility::database($dbname,$host = 'localhost', $ensure = 'present', $charset = 'utf8', $collate = 'utf8_general_ci' ) {
  include '::mysql::client'

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  $db_resource = {
    ensure => $ensure,
    charset => $charset,
    collate => $collate,
    provider => 'mysql',
    require => [Class['mysql::server'], Class['mysql::client']],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

}