# mariadb::backup::mariabackup
#
# Manage MariaDB mariabackup Backup
#
# @summary Manage MariaDB mariabackup Backup
#
# @example
#   include mariadb::backup::mariabackup

class mariadb::backup::mariabackup (
  $mariabackup_package_name = $mariadb::params::backup_package_name,
  $backupuser              = undef,
  $backuppassword          = undef,
  $backupdir               = "${mariadb::params::home}/backups",
  $backupmethod            = 'mariabackup',
  $backupdirmode           = '0700',
  $backupdirowner          = $mariadb::params::user,
  $backupdirgroup          = $mariadb::params::group,
  $backupcompress          = true,
  $initiator_node          = false,
  $backupdatabases         = [],
  $ensure                  = 'present',
  $time                    = ['23', '5'],
  $prescript               = false,
  $postscript              = false,
  $execpath                = '/usr/bin:/usr/sbin:/bin:/sbin',
  $optional_args           = [],
  $additional_cron_args    = '' # lint:ignore:empty_string_assignment
) inherits mariadb::params {

  ensure_packages($mariabackup_package_name)

  $initiator_ensure = $initiator_node ? {
    true    => $ensure,
    default => 'absent',
  }

  if $backupuser and $backuppassword {
    mysql_user { "${backupuser}@localhost":
      ensure        => $ensure,
      password_hash => mysql::password($backuppassword),
      require       => Class['mysql::server::root_password'],
    }

    mysql_grant { "${backupuser}@localhost/*.*":
      ensure     => $ensure,
      user       => "${backupuser}@localhost",
      table      => '*.*',
      privileges => [ 'RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT' ],
      require    => Mysql_user["${backupuser}@localhost"],
    }
  }

  cron { 'mariabackup':
    ensure  => $initiator_ensure,
    command => "/usr/local/sbin/mariabackup.sh ${additional_cron_args}",
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '0-6',
    require => Package[$mariabackup_package_name],
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

  file { 'mariabackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/mariabackup.sh',
    mode    => '0700',
    owner   => $backupdirowner,
    group   => $backupdirgroup,
    content => template('mariadb/backup/mariabackup.sh.erb'),
  }
}
