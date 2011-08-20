Cisco_config.rb
===============

What is it?
-----------

This library allows one to access Cisco routers and switches configuration via
SNMP.  Using SNMP access it triggers a command on the device that will upload
the configuration file to the TFTP server specified.


How?
----

```ruby
require 'CiscoConfig'

cisco = CiscoConfig.new(:host => 'router0.example.org', :comm => 'secretcommunity')
rnd = cisco.copy_from_cisco('tftpserver.example.com', 'config/cisco0.conf')
```

This snipplet will tell the device accessible via 'router0.example.com' to upload it's
configuration to the TFTP sever at 'tftpserver.example.com'.  The second argument of
the `copy_from_cisco` method is the actual filename to save the configuration to.
You should also specifiy the SNMP community configured on your device via the `:comm`
keyword argument of the constructor.


Interface
---------

The `CiscoConfig` class provides the following methods:

* `new(config = {})`.  The constructor accepts the Hash table containing the device access
   configuration.  Specifically, the following options are supported right now:
   * :host -- the hostname of the device
   * :port -- the device SNMP port
   * :comm -- SNMP community name.

* `copy_from_cisco(tftp_host, tftp_file)`.  This method triggers the device upload command.
  The configuration file will be uploaded to the host identified by `tftp_host` under
  the `tftp_file` filename.  The destination directory of `tftp_file` should already exist.
  The method will return numerical ID of the command, which can be used to check for the
  status later.

* `get_status(id, timeout = 10)`.  This method returns the status of the previous command
  identified by 'id'.  It will wait up to `timeout` seconds for the operation to complete if
  it is in progress.


Comments
--------

Send your comments and/or suggestions to <stas@FreeBSD.org>.
