# auth.pp
# Manage wsrep_sst_auth user.
# This user is used to sync between cluster nodes and thus needs root like access to everything.
#

class mariadb::cluster::auth {

  if $mariadb::cluster::wsrep_sst_password != 'UNSET' {
    $wsrep_sst_peers = any2array($mariadb::cluster::wsrep_sst_user_peers)
    $wsrep_sst_users = prefix($wsrep_sst_peers, "${mariadb::cluster::wsrep_sst_user}@")

    mariadb::cluster::wsrep_sst_user { $wsrep_sst_users:
      wsrep_sst_password           => $mariadb::cluster::wsrep_sst_password,
      wsrep_sst_user_tls_options   => $mariadb::cluster::wsrep_sst_user_tls_options,
      wsrep_sst_user_grant_options => $mariadb::cluster::wsrep_sst_user_grant_options,
    }
  }
}
