# repo.pp
# Manage the mariadb repo.
#

class mariadb::repo (
  $repo_version = $mariadb::params::repo_version,
  $percona_repo = false,
) inherits mariadb::params {

  validate_re($repo_version, '^\d+\.?\d*$')
  validate_bool($percona_repo)

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
      include '::mariadb::repo::yum'
    }
    'Debian': {
      include '::mariadb::repo::apt'
    }
    default: {
      fail("Unsupported managed repository for osfamily: ${::osfamily}, module ${module_name} currently only supports managing repos for osfamily RedHat and Debian")
    }
  }
}
