include hadoop
include master_server_client

group { "puppet":
  ensure => "present"
}

exec { 'apt-get update':
  command => '/usr/bin/apt-get update',
  provider => shell,
  unless => "ls /usr/lib/jvm | grep java-6-openjdk-amd64"
}

package { "openjdk-6-jdk":
  ensure => present,
  require => Exec['apt-get update']
}

if $hostname == "master" {
  include master_server
}

group { "hadoop":
  ensure => present
}

user { "hduser":
  ensure => present,
  managehome => true,
  groups => ["hadoop"],
  shell => "/bin/bash"
}

file { "/home/hduser/.ssh":
  ensure => directory,
  mode => 700,
  owner => hduser,
  group => hadoop,
}

file { "/home/hduser/.ssh/id_rsa":
  source => "puppet:///modules/hadoop/id_rsa",
  mode => 600,
  owner => hduser,
  group => hadoop,
  require => File['/home/hduser/.ssh']
}

file { "/home/hduser/.ssh/id_rsa.pub":
  source => "puppet:///modules/hadoop/id_rsa.pub",
  mode => 644,
  owner => hduser,
  group => hadoop,
  require => File['/home/hduser/.ssh']
}

ssh_authorized_key { "ssh_key":
  ensure => present,
  key => "CHANGE_THIS_KEY_ACCORDINGLY!",
  type => "ssh-rsa",
  user => hduser,
  require => File['/home/hduser/.ssh/id_rsa.pub']
}
