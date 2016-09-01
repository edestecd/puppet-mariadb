# See README.md for details.
define mariadb::db_grant (
  $user,
  $dbname  = $name,
  $host    = 'localhost',
  $grant   = 'ALL',
  $options = undef,
  $ensure  = 'present',
) {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  $table = "${dbname}.*"

  include '::mysql::client'

  $grant_resource = {
    ensure     => $ensure,
    privileges => $grant,
    provider   => 'mysql',
    user       => "${user}@${host}",
    table      => $table,
    #options    => $options,
    require    => Class['mysql::server'],
  }
  ensure_resource('mysql_grant', "${user}@${host}/${table}", $grant_resource)
}
