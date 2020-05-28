# See README.md for details.
define mariadb::db_grant (
  $user,
  $dbname  = $name,
  $host    = 'localhost',
  $grant   = 'ALL',
  $options = undef,
  Enum['present', 'absent'] $ensure = 'present',
) {

  $table = "${dbname}.*"

  include 'mysql::client'

  $grant_resource = {
    ensure     => $ensure,
    privileges => $grant,
    provider   => 'mysql',
    user       => "${user}@${host}",
    table      => $table,
    # options    => $options,
    require    => Class['mysql::server'],
  }
  ensure_resource('mysql_grant', "${user}@${host}/${table}", $grant_resource)
}
