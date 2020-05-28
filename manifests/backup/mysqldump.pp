# mariadb::backup::mysqldump
#
# Manage MariaDB Galera Cluster Backup
#
# @summary Manage MariaDB Galera Cluster Backup
#
# @example
#   include mariadb::backup::mysqldump
class mariadb::backup::mysqldump (
  $backupuser         = '', # lint:ignore:empty_string_assignment
  $backuppassword     = '', # lint:ignore:empty_string_assignment
  $backupdir          = '', # lint:ignore:empty_string_assignment
  $maxallowedpacket   = '1M',
  $backupdirmode      = '0700',
  $backupdirowner     = $mariadb::params::user,
  $backupdirgroup     = $mariadb::params::group,
  $backupcompress     = true,
  $backuprotate       = 30,
  $initiator_node     = false,
  $ignore_events      = true,
  $delete_before_dump = false,
  $backupdatabases    = [],
  $file_per_database  = false,
  $include_triggers   = false,
  $include_routines   = false,
  $ensure             = 'present',
  $time               = ['23', '5'],
  $prescript          = false,
  $postscript         = false,
  $execpath           = '/usr/bin:/usr/sbin:/bin:/sbin',
  $optional_args      = [],
) inherits mariadb::params {

  include 'mariadb::cluster'

  if $backupcompress {
    ensure_packages(['bzip2'])
    Package['bzip2'] -> File['wsrep_sst_backup']
  }

  $initiator_ensure = $initiator_node ? {
    true    => $ensure,
    default => 'absent',
  }

  $galera_options = $mariadb::cluster::galera_config::options['mysqld']

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql::password($backuppassword),
    require       => Class['mysql::server::root_password'],
  }

  if $include_triggers  {
    $privs = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS', 'TRIGGER' ]
  } else {
    $privs = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS' ]
  }

  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => $privs,
    require    => Mysql_user["${backupuser}@localhost"],
  }

  $wsrep_provider_options = $galera_options['wsrep_provider_options'] ? {
    undef   => undef,
    default => ";${galera_options['wsrep_provider_options']}",
  }

  # lint:ignore:strict_indent
  $garbd_conf = @("END"/L)
    address = ${galera_options['wsrep_cluster_address']}
    group = ${mariadb::cluster::wsrep_cluster_name}
    options = gmcast.listen_addr=tcp://0.0.0.0:4444${wsrep_provider_options}
    sst = backup
    log = /var/log/garbd.log
    | END
  # lint:endignore

  file { 'garbd.conf':
    ensure  => $ensure,
    path    => '/etc/garbd.conf',
    mode    => '0700',
    owner   => 'root',
    group   => $::mysql::params::root_group,
    content => $garbd_conf.delete("'"),
  }

  cron { 'mysql-backup':
    ensure  => $initiator_ensure,
    command => 'garbd --cfg /etc/garbd.conf',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    require => File['wsrep_sst_backup', 'garbd.conf'],
  }

  file { 'wsrep_sst_backup':
    ensure  => $ensure,
    path    => '/bin/wsrep_sst_backup',
    mode    => '0700',
    owner   => $backupdirowner,
    group   => $backupdirgroup,
    content => template('mysql/mysqlbackup.sh.erb'),
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }
}
