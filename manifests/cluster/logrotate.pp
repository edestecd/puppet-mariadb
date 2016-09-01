# config.pp
# Manage logrotate config to point to correct log dir.
#

class mariadb::cluster::logrotate {

  # vars needed for templates

  file { '/etc/logrotate.d/mysql':
    ensure  => file,
    owner   => 'root',
    group   => $mysql::params::root_group,
    mode    => '0644',
    content => template("${module_name}/config/mysql.logrotate.erb"),
  }
}
