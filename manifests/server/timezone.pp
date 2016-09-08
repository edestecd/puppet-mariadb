# timezone.pp
# Set up MySQL Server Time Zone Support.
#
# http://dev.mysql.com/doc/refman/5.6/en/time-zone-support.html
#
# Some Rails apps need this for charting:
#  http://ankane.github.io/chartkick/
#  https://github.com/ankane/groupdate
#
# mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
#
#

class mariadb::server::timezone {

  $tzinfo_command   = 'mysql_tzinfo_to_sql /usr/share/zoneinfo'
  # replicate_myisam is failing here... so disable it and do it on all nodes instead
  # This feature is experimental anyways and not recommended on production, so why set it GLOBALLY ???
  # $no_wsrep_command = "sed 's/SET GLOBAL wsrep_replicate_myisam.*;/SET SESSION wsrep_on=OFF;/'" # SET SESSION wsrep_on=OFF;

  $mysql_command = join(['mysql', "--defaults-extra-file=${::root_home}/.my.cnf"], ' ')
  $mysql_execute = join([$mysql_command, '-NBe'], ' ')

  # Run sql to set up time zones
  exec { 'mysql_load_timezone_support':
    command   => "${tzinfo_command} | ${mysql_command} mysql",
    cwd       => $mysql::params::datadir,
    onlyif    => "${mysql_execute} 'SELECT COUNT(*) = 0 FROM mysql.time_zone_name;' | grep -q 1",
    logoutput => on_failure,
    path      => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin'],
  }
}
