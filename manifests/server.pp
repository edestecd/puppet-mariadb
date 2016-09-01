# server.pp
# MariaDB Server
#
#
# provided by
#
#

class mariadb::server (
  $auth_pam              = $mariadb::params::auth_pam,
  $restart               = true,
  $service_enabled       = true,
  $service_manage        = true,

  $auth_pam_plugin       = $mariadb::params::auth_pam_plugin,
) inherits mariadb::params {

  # Not Used
  fail("The ${module_name} module does not support the ${name} class yet.
  Please implement it!")

}
