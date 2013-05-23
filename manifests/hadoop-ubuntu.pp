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

# package { "vim":
#   ensure => present,
#   require => Exec['apt-get update']
# }

group { "hadoop":
  ensure => present
}

user { "hduser":
  ensure => present,
  managehome => true,
  groups => "hadoop"
}
