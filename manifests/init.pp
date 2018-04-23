# init.pp
# Main class of mariadb
# Declare main config here
#

class mariadb (
  $user  = $mariadb::params::user,
  $group = $mariadb::params::group,
) inherits mariadb::params {

  # Not Used
  fail("The ${module_name} module does not use the ${name} class. Try one of: mariadb::client mariadb::cluster mariadb::server")
}
