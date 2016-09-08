# Fact: wsrep_status
#
# Purpose: get wsrep_status for Galera Cluster
#
# Resolution:
#   Tests for presence of mysql, returns nil if not present
#   returns hash output of all wsrep% status vars
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

Facter.add(:wsrep_status) do
  setcode do
    if Facter::Util::Resolution.which('mysql') && File.file?(defaults_extra_file)
      query = Facter::Util::Resolution.exec(mysql_execute("SHOW STATUS LIKE 'wsrep%';"))
      Hash[query.split("\n").map { |t| t.split("\t") }] unless !query || query.empty?
    end
  end
end
