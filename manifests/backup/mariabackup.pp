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
  $backupdir               = $mariadb::params::backupdir,
  $backupmethod            = 'mariabackup',
  $backupdirmode           = '0700',
  $backupdirowner          = 'root',
  $backupdirgroup          = 'root',
  $backupcompress          = true,
  $backupdatabases         = [],
  $ensure                  = 'present',
  $time                    = ['23', '5'],
  $prescript               = false,
  $postscript              = false,
  $execpath                = '/usr/bin:/usr/sbin:/bin:/sbin',
  $optional_args           = [],
  $additional_cron_args    = '', # lint:ignore:empty_string_assignment
  $incremental             = true,
  $logging_enabled         = false,
  $log_path                = $mariadb::params::home,
  $log_file                = 'mariabackup.log'
) inherits mariadb::params {

  ensure_packages($mariabackup_package_name)

  $_redirect = $logging_enabled ? {
    true    => ">>${log_path}/${log_file} 2>&1",
    default => undef,
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
    ensure  => $ensure,
    command => "/usr/local/sbin/mariabackup.sh ${additional_cron_args}${_redirect}",
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
    owner   => 'root',
    group   => 'root',
    content => template('mariadb/backup/mariabackup.sh.erb'),
  }
}
