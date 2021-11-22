require "spec_helper"
require "serverspec"

package = "icinga2"
service = "icinga2"
config  = "/etc/icinga2/icinga2.conf"
user    = "icinga2"
group   = "icinga2"
ports   = [PORTS]
log_dir = "/var/log/icinga2"
db_dir  = "/var/lib/icinga2"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/icinga2.conf"
  db_dir = "/var/db/icinga2"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("icinga2") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/icinga2") do
    it { should be_file }
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
