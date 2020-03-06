# apt.pp
# Manage the percona apt repo.
#

class mariadb::repo::percona::apt {
  include apt

  apt::source { 'percona-release':
    location => 'http://repo.percona.com/apt',
    repos    => 'main',
    key      => {
      'id' => '430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A',
    },
  }
  Apt::Source['percona-release'] -> Class['apt::update'] -> Package<| tag == 'percona' |>
}
