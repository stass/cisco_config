#
# A Ruby library to fetch Cisco IOS configuration via SNMP
#
# Copyright (C) 2007-2008 Stanislav Sedov <stas@FreeBSD.org>
#
# This file is in public domain
#

#
# See http://www.cisco.com/en/US/tech/tk648/tk362/technologies_tech_note09186a0080094aa6.shtml
# for additional info.
#

require 'snmp'

class CiscoConfig

  #
  # OIDs from CISCO-CONFIG-COPY-MIB-V1SMI
  #
  OIDPrefix = '1.3.6.1.4.1.9.9.96.1.1.1.1'	# common prefix

  OIDMap = {		# name -> oid mappings
    :CopyProtocol => 2,
    :CopySourceFileType => 3,
    :CopyDestFileType => 4,
    :CopyServerAddress => 5,
    :CopyFileName => 6,
    :CopyState => 10,
    :CopyFailCause => 13,
    :CopyEntryRowStatus => 14
  }

  #
  # Error codes
  #
  REQSTATUS = {
    1 => "unknown error",
    2 => "access denied",
    3 => "TFTP operation timed out",
    4 => "out of memory",
    5 => "no configuration",
  }
		
  #
  # Default configuration
  #
  Defconfig = {
	:host => 'localhost',
	:port => 161,
	:comm => 'public',
  }

  def initialize(newconf = {})
    @config = Defconfig.merge(newconf)

    @manager = SNMP::Manager.new(:Host => @config[:host], :Port => @config[:port], \
			   :Community => @config[:comm])

    self
  end

  def copy_from_cisco(host, file)
    id = cisco_rand	# this will became the new id
    status = 0

    req = Array.new()
    req[0] = SNMP::VarBind.new get_oid(:CopyProtocol, id), SNMP::Integer.new(1)
    req[1] = SNMP::VarBind.new get_oid(:CopySourceFileType, id), SNMP::Integer.new(4)
    req[2] = SNMP::VarBind.new get_oid(:CopyDestFileType, id), SNMP::Integer.new(1)
    req[3] = SNMP::VarBind.new get_oid(:CopyServerAddress, id), SNMP::IpAddress.new(host)
    req[4] = SNMP::VarBind.new get_oid(:CopyFileName, id), SNMP::OctetString.new(file)
    req[5] = SNMP::VarBind.new get_oid(:CopyEntryRowStatus, id), SNMP::Integer.new(4)

    @manager.set(req)

    id
  end

  def get_status(id, timeout = 10)
    status = 0
    time = 0
    while (time < 10) do
      status = @manager.get_value(get_oid(:CopyState, id)).to_i
      break if status > 2
      sleep(1)
    end

    return "timed out" if time == 10

    if (status == 3) then
      return "OK"
    end

    err = @manager.get_value(get_oid(:CopyFailCause, id)).to_i

    REQSTATUS[err]
  end

  #
  # Return random number suitable to use in Cisco OIDs.
  # It looks like that only 24 bits are allowed
  #
  def cisco_rand
    rand(1 << 24)
  end

  private :cisco_rand

  #
  # Returns full IOS OID according to name provided
  #
  def get_oid(name, id)
    OIDPrefix + '.' + OIDMap[name].to_s + ".#{id}"
  end

  private :get_oid
end
