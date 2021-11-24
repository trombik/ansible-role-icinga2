require "spec_helper"
require "serverspec"

package = "icinga2"
service = "icinga2"
config_dir  = case os[:family]
              when "freebsd"
                "/usr/local/etc/icinga2"
              else
                "/etc/icinga2/icinga2.conf"
              end
user    = "icinga"
group   = "icinga"
ports   = []
# log_dir = "/var/log/icinga2"
features = %w[ checker ido-pgsql mainlog notification ]
config_files = %w[
  icinga2.conf
  zones.conf
  constants.conf
  conf.d/api-users.conf
  conf.d/app.conf
  conf.d/commands.conf
  conf.d/downtimes.conf
  conf.d/groups.conf
  conf.d/hosts.conf
  conf.d/notifications.conf
  conf.d/services.conf
  conf.d/templates.conf
  conf.d/timeperiods.conf
  conf.d/users.conf
  features-available/checker.conf
  features-available/ido-pgsql.conf
  features-available/mainlog.conf
  features-available/notification.conf
]
db_user = "icinga_ido"
db_name = "icinga_ido"
db_password = "password"

describe package(package) do
  it { should be_installed }
end

config_files.each do |f|
  describe file("#{config_dir}/#{f}") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
  end
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/icinga2") do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/Managed by ansible/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command "env PGPASSWORD=#{db_password} psql --host 127.0.0.1 --user #{db_user} -c 'SELECT * FROM icinga_zones' #{db_name}" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/zone_id\s+\|\s+instance_id\s+\|\s+zone_object_id\s+\|\s+parent_zone_object_id\s+\|\s+config_type\s+\|\s+is_global\s+\|\s+config_hash/) }
end
