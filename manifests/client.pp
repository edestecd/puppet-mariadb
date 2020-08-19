# client.pp
# MariaDB
# Client application
# Optional Development libs and headers
#
#
# gives you the mysql terminal etc...
#
# Gives you libs and headers to compile mysql clients...
# For example, these are required to build/install
# the ruby gems mysql and mysql2
#
#

class mariadb::client (
  Boolean $manage_repo = $mariadb::params::manage_repo,
  $repo_version        = $mariadb::params::repo_version,
  Boolean $dev         = true,
  Stdlib::Absolutepath $config_dir = $mariadb::params::config_dir,
  $override_options    = {},
) inherits mariadb::params {

  $options = mysql::normalise_and_deepmerge($mariadb::params::client_default_options, $override_options)

  if $manage_repo {
    class { 'mariadb::repo':
      repo_version => $repo_version,
    }
  }

  anchor { 'mariadb::client::start': }
  -> class { 'mariadb::client::mysql': }
  -> class { 'mariadb::client::config': }
  -> anchor { 'mariadb::client::end': }
}
