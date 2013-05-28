class master_server_client {
  file { "/usr/local/bin/register":
    source => "puppet:///modules/master_server_client/register",
    mode => 755,
    owner => root,
    group => root
  }

  file { "/usr/local/bin/fetch_etc_hosts":
    source => "puppet:///modules/master_server_client/fetch_etc_hosts",
    mode => 755,
    owner => root,
    group => root
  }
}
