# apt.pp
# Manage the mariadb apt repo.
#

class mariadb::repo::apt {
  include ::apt

  $version = $mariadb::repo::repo_version
  $os      = $mariadb::repo::os

  apt::source { 'mariadb':
    location => "http://nyc2.mirrors.digitalocean.com/mariadb/repo/${version}/${os}",
    repos    => 'main',
    key      => {
      'id' => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    },
  }
  # lint:ignore:spaceship_operator_without_tag
  Apt::Source['mariadb'] -> Class['apt::update'] -> Package<| |>
  # lint:endignore
}
