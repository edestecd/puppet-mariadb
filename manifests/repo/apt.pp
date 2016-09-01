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

  if $mariadb::repo::percona_repo {
    apt::source { 'percona-release':
      location => 'http://repo.percona.com/apt',
      repos    => 'main',
      key      => {
        'id' => '430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A',
      },
    }
    # lint:ignore:spaceship_operator_without_tag
    Apt::Source['percona-release'] -> Class['apt::update'] -> Package<| |>
    # lint:endignore
  }
}
