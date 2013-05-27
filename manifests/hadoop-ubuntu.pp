include hadoop

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
  groups => "hadoop",
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
  key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQC4xZz7A8GKviAr3jnBxPODyOU3czTCV8p55TEKl03bh9af9nkXV57KxeK0eGvz1A6kWENvzQF1X9BojbOvE1kSVF99g4SqP4f4sQY9W+sj8thQxM4p2lmB748XHFnGVq6wC3enGZ8zwTu57CCy8rPJ8joYIUAxBnbriKU9E89JP54fCuptlmSzUFzQ/+vTBtDcj1b8BxKYd2DM3/0CuHY3Lejk6FBlyaf0e14+ENQjgsNBk3d3SyfINkXNQjA/zax6Qqq8j9TpC3Aa1rEKDUPayw5CrEQV5NsSclyfDDInUNsdEbFgWC2+HMEQpOSo7K7anzrfmA7bpto2AXF5zu4z",
  type => "ssh-rsa",
  user => hduser,
  require => File['/home/hduser/.ssh/id_rsa.pub']
}
