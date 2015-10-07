# == Class: snmp::params
#
# This class handles OS-specific configuration of the snmp module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class snmp::params {
  $agentaddress = [ 'udp:127.0.0.1:161', 'udp6:[::1]:161' ]
  $snmptrapdaddr = [ 'udp:127.0.0.1:162', 'udp6:[::1]:162' ]
  $ro_community = 'public'
  $ro_community6 = 'public'
  $rw_community = undef
  $rw_community6 = undef
  $ro_network = '127.0.0.1'
  $ro_network6 = '::1'
  $rw_network = '127.0.0.1'
  $rw_network6 = '::1'
  $contact = 'Unknown'
  $location = 'Unknown'
  $sysname = $::fqdn
  $com2sec = [
      "notConfigUser  default       public",
    ]
  $com2sec6 = [
      "notConfigUser  default       public",
    ]
  $groups = [
      'notConfigGroup v1            notConfigUser',
      'notConfigGroup v2c           notConfigUser',
    ]
  $services = 72
  $openmanage_enable = false
  $views = [
      'systemview    included   .1.3.6.1.2.1.1',
      'systemview    included   .1.3.6.1.2.1.25.1.1',
    ]
  $accesses = [
      'notConfigGroup ""      any       noauth    exact  systemview none  none',
    ]
  $dlmod = []
  $disable_authorization = 'no'
  $do_not_log_traps = 'no'
  $do_not_log_tcpwrappers = 'no'
  $trap_handlers = []
  $trap_forwards = []
  $snmp_config   = []
  $snmpd_config = []
  $snmptrapd_config = []

### The following parameters should not need to be changed.

  $ensure = 'present'
  $service_ensure = 'running'
  $trap_service_ensure = 'stopped'

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $autoupgrade = false
  $install_client = undef
  $manage_client = false
  $service_enable = true
  $service_hasstatus = true
  $service_hasrestart = true
  $trap_service_enable = false
  $trap_service_hasstatus = true
  $trap_service_hasrestart = true

  case $::osfamily {
    'RedHat': {
      if $::operatingsystemmajrelease { # facter 1.7+
        $majdistrelease = $::operatingsystemmajrelease
      } elsif $::lsbmajdistrelease {    # requires LSB to already be installed
        $majdistrelease = $::lsbmajdistrelease
      } else {
        $majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')
      }
      case $::operatingsystem {
        'Fedora': {
          $snmpd_options     = '-LS0-6d'
          $snmptrapd_options = '-Lsd'
          $sysconfig         = '/etc/sysconfig/snmpd'
          $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
          $var_net_snmp      = '/var/lib/net-snmp'
          $varnetsnmp_perms  = '0755'
        }
        default: {
          if $majdistrelease <= '5' {
            $snmpd_options     = '-Lsd -Lf /dev/null -p /var/run/snmpd.pid -a'
            $sysconfig         = '/etc/sysconfig/snmpd.options'
            $trap_sysconfig    = '/etc/sysconfig/snmptrapd.options'
            $var_net_snmp      = '/var/net-snmp'
            $varnetsnmp_perms  = '0700'
            $snmptrapd_options = '-Lsd -p /var/run/snmptrapd.pid'
          } elsif $majdistrelease == '6' {
            $snmpd_options     = '-LS0-6d -Lf /dev/null -p /var/run/snmpd.pid'
            $sysconfig         = '/etc/sysconfig/snmpd'
            $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
            $var_net_snmp      = '/var/lib/net-snmp'
            $varnetsnmp_perms  = '0755'
            $snmptrapd_options = '-Lsd -p /var/run/snmptrapd.pid'
          } else {
            $snmpd_options     = '-LS0-6d'
            $sysconfig         = '/etc/sysconfig/snmpd'
            $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
            $var_net_snmp      = '/var/lib/net-snmp'
            $varnetsnmp_perms  = '0755'
            $snmptrapd_options = '-Lsd'
          }
        }
      }
      $package_name             = 'net-snmp'
      $service_config           = '/etc/snmp/snmpd.conf'
      $service_config_perms     = '0644'
      $service_config_dir_group = 'root'
      $service_name             = 'snmpd'
      $varnetsnmp_owner         = 'root'
      $varnetsnmp_group         = 'root'

      $client_package_name      = 'net-snmp-utils'
      $client_config            = '/etc/snmp/snmp.conf'

      $trap_service_config      = '/etc/snmp/snmptrapd.conf'
      $trap_service_name        = 'snmptrapd'
    }
    'Debian': {
      $package_name             = 'snmpd'
      $service_config           = '/etc/snmp/snmpd.conf'
      $service_config_perms     = '0600'
      $service_config_dir_group = 'root'
      $service_name             = 'snmpd'
      $snmpd_options            = '-Lsd -Lf /dev/null -u snmp -g snmp -I -smux -p /var/run/snmpd.pid'
      $sysconfig                = '/etc/default/snmpd'
      $var_net_snmp             = '/var/lib/snmp'
      $varnetsnmp_perms         = '0755'
      $varnetsnmp_owner         = 'snmp'
      $varnetsnmp_group         = 'snmp'

      $client_package_name      = 'snmp'
      $client_config            = '/etc/snmp/snmp.conf'

      $trap_service_config      = '/etc/snmp/snmptrapd.conf'
      $snmptrapd_options        = '-Lsd -p /var/run/snmptrapd.pid'
    }
    'Suse': {
      $package_name             = 'net-snmp'
      $service_config           = '/etc/snmp/snmpd.conf'
      $service_config_perms     = '0600'
      $service_config_dir_group = 'root'
      $service_name             = 'snmpd'
      $snmpd_options            = 'd'
      $sysconfig                = '/etc/sysconfig/net-snmp'
      $var_net_snmp             = '/var/lib/net-snmp'
      $varnetsnmp_perms         = '0755'
      $varnetsnmp_owner         = 'root'
      $varnetsnmp_group         = 'root'

      $client_package_name      = 'net-snmp'
      $client_config            = '/etc/snmp/snmp.conf'

      $trap_service_config      = '/etc/snmp/snmptrapd.conf'
      $trap_service_name        = 'snmptrapd'
      $snmptrapd_options        = undef
    }
    'FreeBSD': {
      $package_name             = 'net-mgmt/net-snmp'
      $service_config_dir_path  = '/usr/local/etc/snmp'
      $service_config_dir_perms = '0755'
      $service_config_dir_owner = 'root'
      $service_config_dir_group = 'wheel'
      $service_config           = '/usr/local/etc/snmp/snmpd.conf'
      $service_config_perms     = '0755'
      $service_name             = 'snmpd'
      $snmpd_options            = 'd'
      $var_net_snmp             = '/var/net-snmp'
      $varnetsnmp_perms         = '0600'
      $varnetsnmp_owner         = 'root'
      $varnetsnmp_group         = 'wheel'

      $client_package_name      = 'net-mgmt/net-snmp'
      $client_config            = '/usr/local/etc/snmp/snmp.conf'

      $trap_service_config      = '/usr/local/etc/snmp/snmptrapd.conf'
      $trap_service_name        = 'snmptrapd'
      $snmptrapd_options        = undef
    }
    default: {
      fail("Module ${::module} is not supported on ${::operatingsystem}")
    }
  }
}
