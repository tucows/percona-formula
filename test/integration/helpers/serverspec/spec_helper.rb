require 'serverspec'
require 'yaml'

set :backend, :exec

system "salt-call --local --config-dir=/tmp/kitchen/etc/salt -l quiet cp.get_template salt://mysql/files/rawmap.yml /tmp/mysql.config 2>&1 > /dev/null"

# Configure OS specific parameters
if ['debian', 'ubuntu'].include?(os[:family])
  $codename = `cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d\= -f 2 | tr -d '\n\r'`
  unless File.exists?('/bin/netstat')
    system "apt-get install -y net-tools"
  end
else
  # Install netstat that is needed to check port is listening
end
