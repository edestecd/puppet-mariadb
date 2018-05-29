# yum.pp
# Manage the percona yum repo.
#

class mariadb::repo::percona::yum {

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
