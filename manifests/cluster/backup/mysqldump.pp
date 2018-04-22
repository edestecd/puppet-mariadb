# mariadb/cluster/backup/mysqldump.pp
# Manage MariaDB Galera Cluster Backup

class mariadb::cluster::backup::mysqldump (
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
  $galara_port        = '4567',
  $delete_before_dump = false,
  $backupdatabases    = [],
  $include_triggers   = false,
  $include_routines   = false,
  $ensure             = 'present',
  $time               = ['23', '5'],
  $prescript          = false,
  $postscript         = false,
  $execpath           = '/usr/bin:/usr/sbin:/bin:/sbin',
  $optional_args      = [],
) inherits mariadb::params {

  include '::mariadb::cluster'

  if $backupcompress {
    ensure_packages(['bzip2'])
  }

  $initiator_ensure = $initiator_node ? {
    true    => $ensure,
    default => 'absent',
  }

  $galera_options = $mariadb::cluster::galera_config::options['mysqld']

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
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

  $garb_address = join($mariadb::cluster::wsrep_cluster_peers.suffix(":${galara_port}"), ',')
  $wsrep_provider_options = $galera_options['wsrep_provider_options'] ? {
    undef   => undef,
    default => ";${galera_options['wsrep_provider_options']}",
  }

  $_wsrep_provider_options = $wsrep_provider_options.delete("'")

  # lint:ignore:strict_indent
  $garbd_conf_template = @(END)
    address = gcomm://<%= scope['garb_address'] %>
    group = <%= scope['mariadb::cluster::wsrep_cluster_name'] %>
    options = gmcast.listen_addr=tcp://0.0.0.0:4444<%= scope['_wsrep_provider_options'] %>
    sst = backup
    log = /var/log/garbd.log
  END
  # lint:endignore

  file { 'garbd.conf':
    ensure  => $ensure,
    path    => '/etc/garbd.conf',
    mode    => '0700',
    owner   => 'root',
    group   => $::mysql::params::root_group,
    content => inline_template($garbd_conf_template),
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
    mode    => '0755',
    owner   => 'root',
    group   => $mysql::params::root_group,
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
