# yum.pp
# Manage the mariadb yum repo.
#

class mariadb::repo::yum {
  $version = $mariadb::repo::repo_version
  $os      = $mariadb::repo::os
  $arch    = $mariadb::repo::arch

  yumrepo { 'mariadb':
    baseurl  => "http://yum.mariadb.org/${version}/${os}${::operatingsystemmajrelease}-${arch}",
    descr    => 'MariaDB',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
  }
  # lint:ignore:spaceship_operator_without_tag
  Yumrepo['mariadb'] -> Package<| |>
  # lint:endignore

  if $mariadb::repo::percona_repo {
    yumrepo { 'percona-release':
      baseurl  => "http://repo.percona.com/release/${::operatingsystemmajrelease}/RPMS/${::architecture}",
      descr    => 'Percona-Release',
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => 'https://www.percona.com/downloads/RPM-GPG-KEY-percona',
    }
    # lint:ignore:spaceship_operator_without_tag
    Yumrepo['percona-release'] -> Package<| |>
    # lint:endignore
  }
}
