# apt.pp
# Manage the mariadb apt repo.
#

class mariadb::repo::apt {
  include apt

  $version = $mariadb::repo::repo_version
  $os      = $mariadb::repo::os
  if (($::operatingsystem == 'Debian') and (versioncmp($::operatingsystemrelease, '9.0') >= 0)) or
  (($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemrelease, '16.04') >= 0)) {
    $key = {
      'id' => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    }
  } else {
    $key = {
      'id' => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    }
  }

  apt::source { 'mariadb':
    location => "http://nyc2.mirrors.digitalocean.com/mariadb/repo/${version}/${os}",
    repos    => 'main',
    key      => $key,
  }
  # lint:ignore:spaceship_operator_without_tag
  Apt::Source['mariadb'] -> Class['apt::update'] -> Package<| |>
  # lint:endignore
}
