# auth.pp
# Manage wsrep_sst_auth user.
# This user is used to sync between cluster nodes and thus needs root like access to everything.
#

class mariadb::cluster::auth {

  if $mariadb::cluster::wsrep_sst_password != 'UNSET' {
    mysql_user { "${mariadb::cluster::wsrep_sst_user}@%":
      ensure        => present,
      password_hash => mysql_password($mariadb::cluster::wsrep_sst_password),
      require       => Class['::mysql::server::root_password'],
    }

    mysql_grant { "${mariadb::cluster::wsrep_sst_user}@%/*.*":
      ensure     => present,
      user       => "${mariadb::cluster::wsrep_sst_user}@%",
      table      => '*.*',
      privileges => ['ALL'],
      require    => Mysql_user["${mariadb::cluster::wsrep_sst_user}@%"],
    }
  }
}
