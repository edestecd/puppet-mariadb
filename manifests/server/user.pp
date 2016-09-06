# user.pp
# Manage user/group.
#

class mariadb::server::user {

  if $mariadb::server::group {
    group { 'mysql':
      ensure => present,
      name   => $mariadb::server::group,
      gid    => $mariadb::server::gid,
      system => true,
    }
  }

  if $mariadb::server::user {
    user { 'mysql':
      ensure  => present,
      name    => $mariadb::server::user,
      comment => $mariadb::server::comment,
      uid     => $mariadb::server::uid,
      gid     => $mariadb::server::gid,
      groups  => $mariadb::server::groups,
      home    => $mariadb::server::home,
      shell   => $mariadb::server::shell,
      system  => true,
    }
  }
}
