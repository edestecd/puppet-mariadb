# user.pp
# Manage cluster user/group.
#

class mariadb::cluster::user {

  if $mariadb::cluster::group {
    group { 'mysql':
      ensure => present,
      name   => $mariadb::cluster::group,
      gid    => $mariadb::cluster::gid,
      system => true,
    }
  }

  if $mariadb::cluster::user {
    user { 'mysql':
      ensure  => present,
      name    => $mariadb::cluster::user,
      comment => $mariadb::cluster::comment,
      uid     => $mariadb::cluster::uid,
      gid     => $mariadb::cluster::gid,
      groups  => $mariadb::cluster::groups,
      home    => $mariadb::cluster::home,
      shell   => $mariadb::cluster::shell,
      system  => true,
    }
  }
}
