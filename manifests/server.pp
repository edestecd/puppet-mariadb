# server.pp
# MariaDB Server
#
#
# provided by
#
#

class mariadb::server (
  $manage_user          = $mariadb::params::manage_user,
  $manage_timezone      = $mariadb::params::manage_timezone,
  $manage_repo          = $mariadb::params::manage_repo,
  $repo_version         = $mariadb::params::repo_version,
  $dev                  = true,
  $cluster              = false,
  $restart              = true,
  $service_enabled      = true,
  $service_manage       = true,

  $user                 = $mariadb::params::user,
  $comment              = $mariadb::params::comment,
  $uid                  = $mariadb::params::uid,
  $gid                  = $mariadb::params::gid,
  $home                 = $mariadb::params::home,
  $shell                = $mariadb::params::shell,
  $group                = $mariadb::params::group,
  $groups               = $mariadb::params::groups,

  $config_file          = $mariadb::params::config_file,
  $includedir           = $mariadb::params::includedir,
  $config_dir           = $mariadb::params::config_dir,
  $root_password        = $mariadb::params::root_password,
  $override_options     = {},

  $auth_pam             = $mariadb::params::auth_pam,
  $auth_pam_plugin      = $mariadb::params::auth_pam_plugin,
  $storeconfigs_enabled = false,

  $users                = {},
  $grants               = {},
  $databases            = {},
) inherits mariadb::params {

  validate_bool($manage_user, $manage_repo, $dev)

  $options = mysql_deepmerge($mariadb::params::server_default_options, $override_options)

  if $manage_repo {
    class { '::mariadb::repo':
      repo_version => $repo_version,
    }
  }

  if $manage_user {
    Anchor['mariadb::server::start'] ->
    class { '::mariadb::server::user': } ->
    Class['mariadb::client::mysql']
  }

  if $manage_timezone {
    Class['mariadb::server::mysql'] ->
    class { '::mariadb::server::timezone': } ->
    Anchor['mariadb::server::end']
  }

  anchor { 'mariadb::server::start': } ->
  class { '::mariadb::client::mysql': dev => $dev } ->
  class { '::mariadb::server::mysql': cluster => $cluster } ->
  anchor { 'mariadb::server::end': }

  if $::settings::storeconfigs and $storeconfigs_enabled {
    Mysql::Db <<| tag == $::domain |>> {
      require => Anchor['mariadb::server::end'],
    } ->
    Mariadb::Db_grant <<| tag == $::domain |>> {
      require => Anchor['mariadb::server::end'],
    }
  }
}
