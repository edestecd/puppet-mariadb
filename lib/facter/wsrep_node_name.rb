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

def defaults_extra_file
  "#{Facter.value(:root_home)}/.my.cnf"
end

def mysql_execute(sql)
  mysql_command = ['mysql', "--defaults-extra-file=#{defaults_extra_file}", '-NBe']
  %(#{mysql_command.join(' ')} "#{sql}")
end

Facter.add(:wsrep_node_name) do
  setcode do
    if Facter::Util::Resolution.which('mysql') && File.file?(defaults_extra_file)
      query = Facter::Util::Resolution.exec(mysql_execute("SHOW VARIABLES LIKE 'wsrep_node_name';"))
      query.split("\t").last unless !query || query.empty?
    end
  end
end
