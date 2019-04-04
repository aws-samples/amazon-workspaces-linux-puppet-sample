# Class: linuxws
# ===========================
#
# This module enables Administrators of Amazon Linux 2 based Amazon WorkSpaces to deploy access control settings. 
#
#

class linuxws (
  Array $userlist,
  String $domainname,
  Integer $clipboard = 0,
  Integer $wsloglevel = 1
  ) {

  include ::stdlib
# Sudoers
  class { 'sudo':
    purge               => false,
    config_file_replace => false,
  }
  # Modify default permissions in sudoers.d 
  file { '00-domain-admins':
    path  => '/etc/sudoers.d/00-domain-admins',
    group => 'root',
    owner => 'root',
    mode  => '0440',
  }
  file { '01-ws-admin-user':
    path  => '/etc/sudoers.d/01-ws-admin-user',
    group => 'root',
    owner => 'root',
    mode  => '0440',
  }
  # Add Sudoers.d file for each user or group
  $userlist.each |String $user| {
    sudo::conf { "${domainname}-${user}" :
      priority => 10,
      content  => "%${domainname}\\\\${user} ALL=(ALL) ALL "
    }
  }
# Pcoip-agent.conf
  # Ensure pcoip-agent directory exists and ownership is correct
  file { 'pcoip-directory':
    ensure => directory,
    path   => '/etc/pcoip-agent/',
    mode   => '0755',
    group  => 'root',
    owner  => 'root',
  }

  $epp_args = {
    'clipboard'  => $clipboard,
    'wsloglevel' => $wsloglevel,
  }

  file { 'pcoip-agent-conf':
    ensure  => file,
    path    => '/etc/pcoip-agent/pcoip-agent.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0644',
    content => epp('linuxws/pcoip-agent.conf.epp', $epp_args),
  }

# Access.conf
  $userlist.each |String $user| {
    file_line { "${user}":
      line => "+ : ${domainname}\\${user} : All",
      path => '/etc/security/access.conf',
    }
  }
}
