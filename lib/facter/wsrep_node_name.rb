# Fact: wsrep_node_name
#
# Purpose: get node_name for Galera Cluster
#
# Resolution:
#   Tests for presence of mysql, returns nil if not present
#   returns output of mysql query for variable
#
# Caveats:
#   none
#
# Notes:
#   none

def mysql_execute(sql)
  mysql_command = ['mysql', "--defaults-extra-file=#{Facter.value(:root_home)}/.my.cnf", '-NBe']
  %(#{mysql_command.join(' ')} "#{sql}")
end

Facter.add(:wsrep_node_name) do
  setcode do
    if Facter::Util::Resolution.which('mysql')
      Facter::Util::Resolution.exec(mysql_execute('SELECT @@wsrep_node_name;'))
    end
  end
end
