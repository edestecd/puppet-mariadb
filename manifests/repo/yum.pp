# yum.pp
# Manage the mariadb yum repo.
#

class mariadb::repo::yum {
  $version = $mariadb::repo::repo_version
  $os      = $mariadb::repo::os
  $arch    = $mariadb::repo::arch

  $module_hotfixes = $::operatingsystemmajrelease ? {
    '8'     => '1',
    default => '0',
  }

  yumrepo { 'mariadb':
    baseurl         => "http://yum.mariadb.org/${version}/${os}${::operatingsystemmajrelease}-${arch}",
    descr           => 'MariaDB',
    enabled         => '1',
    gpgcheck        => '1',
    gpgkey          => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
    module_hotfixes => $module_hotfixes,
  }
  # lint:ignore:spaceship_operator_without_tag
  Yumrepo['mariadb'] -> Package<| |>
  # lint:endignore
}
