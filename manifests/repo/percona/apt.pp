# Manage the percona apt repo.

class mariadb::repo::percona::apt {
    include::apt

    if ($::operatingsystem == 'Debian'and versioncmp($::operatingsystemrelease, '8.0') >= 0) or ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '16.04') >= 0) {
        $key = {
            'id' => '4D1BB29D63D98E422B2113B19334A25F8507EFA5',
        }
    } else {
        $key = {
            'id' => '430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A',
        }
    }

    apt::source {
        'percona-release': location => 'http://repo.percona.com/apt',
        repos => 'main',
        key => $key,
    }
    Apt::Source['percona-release'] - > Class['apt::update'] - > Package < | tag == 'percona' | >
}