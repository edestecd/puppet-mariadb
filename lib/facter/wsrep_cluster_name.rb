# Fact: wsrep_cluster_name
#
# Purpose: get cluster_name for Galera Cluster
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

Facter.add(:wsrep_cluster_name) do
  setcode do
    if Facter::Util::Resolution.which('mysql')
      Facter::Util::Resolution.exec(mysql_execute('SELECT @@wsrep_cluster_name;'))
    end
  end
end
