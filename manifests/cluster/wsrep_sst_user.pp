# wsrep_sst_user.pp
# Manage one wsrep_sst_auth user.
# This user is used to sync between cluster nodes and thus needs root like access to everything.
#

define mariadb::cluster::wsrep_sst_user (
  $wsrep_sst_password,
  $wsrep_sst_user               = $name,
  $wsrep_sst_user_tls_options   = undef,
  $wsrep_sst_user_grant_options = undef,
) {

  mysql_user { $wsrep_sst_user:
    ensure        => present,
    password_hash => mysql::password($wsrep_sst_password),
    tls_options   => $wsrep_sst_user_tls_options,
    require       => Class['::mysql::server::root_password'],
  }

  -> mysql_grant { "${wsrep_sst_user}/*.*":
    ensure     => present,
    user       => $wsrep_sst_user,
    table      => '*.*',
    privileges => ['ALL'],
    options    => $wsrep_sst_user_grant_options,
  }
}
