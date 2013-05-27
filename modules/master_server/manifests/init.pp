class master_server {
  $hosts_home = "/app/hosts_file_generator"

  exec { "create_app_folder":
    command => "mkdir -p ${hosts_home} && chown -R hduser:hadoop ${hosts_home}",
    path => $path,
    creates => "${hosts_home}"
  }

  package { "git":
    ensure => present,
    require => Exec['apt-get update']
  }

  exec { "clone_git_repository":
    command => "git clone https://github.com/tomaszj/etc-hosts-generator.git ${hosts_home}",
    path => $path,
    require => Package['git'],
    unless => "ls ${hosts_home}"
  }

  package {"rubygems":
    ensure => present,
    require => Exec['apt-get update']
  }

  exec { "install_bundler":
    command => "gem install bundler",
    path => $path,
    unless => "which bundle",
    require => Package['rubygems']
  }

  package { "libsqlite3-dev":
    ensure => present,
    require => Exec['apt-get update']
  }

  exec { "install_bundled_gems":
    command => "bundle install",
    cwd => "${hosts_home}",
    path => $path,
    require => [ Exec['install_bundler'], Package['libsqlite3-dev'], Exec['clone_git_repository'] ]
  }

  exec { "start_hosts_file_server":
    command => "ruby app.rb -o '0.0.0.0' &",
    cwd => "${hosts_home}",
    path => $path,
    unless => "ps aux | grep '[r]uby app.rb'",
    require => Exec['install_bundled_gems'],
    user => hduser
  }
}
