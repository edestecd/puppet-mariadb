# repo.pp
# Manage the mariadb repo.
#

class mariadb::repo (
  Pattern[/^\d+\.?\d*$/] $repo_version = $mariadb::params::repo_version,
  Boolean $percona_repo = false,
) inherits mariadb::params {

  $os = $::operatingsystem ? {
    'RedHat' => 'rhel',
    'CentOS' => 'centos',
    'Fedora' => 'fedora',
    'Debian' => 'debian',
    'Ubuntu' => 'ubuntu',
  }
  $arch = $::architecture ? {
    'i386'   => 'x86',
    'x86_64' => 'amd64',
    default  => $::architecture,
  }

  case $::osfamily {
    'RedHat': {
      include 'mariadb::repo::yum'
    }
    'Debian': {
      include 'mariadb::repo::apt'
    }
    default: {
      fail("Unsupported managed repository for ${::osfamily}, currently only supports RedHat and Debian")
    }
  }

  if $percona_repo {
    include 'mariadb::repo::percona'
  }
}
