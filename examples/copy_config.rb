#!/usr/bin/env ruby18
#
# This example shows how to use the CiscoConfig library to download the configuration file
# from the Cisco router/swiftch and check it into the repository if it has changed.  This
# script can be run from the cron to keep track of configuration changes.
#
require 'rubygems'
require 'CiscoConfig'

begin
  cisco = CiscoConfig.new(:host => 'router0.example.org', :comm => 'secretcommunity')
  rnd = cisco.copy_from_cisco('tftpserver.example.com', 'config/cisco0.conf')

  status = cisco.get_status(rnd)
  if (status != "OK") then
	puts "Error retrieving config: #{status}"
  end

  system('sed -i ""  -e "/ntp clock-period/d" /mnt/tftpserver/tftproot/config/cisco0.conf')

  lines = `(cd /mnt/tftpserver/tftproot/config && /usr/local/bin/hg diff) 2>/dev/null | wc -l`.to_i
  exit if (lines == 0)

  system("cd /mnt/tftpserver/tftproot/config && /usr/local/bin/hg ci -m 'cisco0 config autocommit' 2>/dev/null")
end
