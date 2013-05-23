class hadoop {
  $hadoop_home = "/usr/local/hadoop"
  $master_ip = "192.168.2.10"

  $hadoop_tmp_parent_folder = "/app/hadoop"
  $hadoop_tmp_folder_name = "tmp"
  $hadoop_tmp_path = "${hadoop_tmp_parent_folder}/${hadoop_tmp_folder_name}"

  exec { "download_hadoop":
    command => "wget -O /tmp/hadoop.tar.gz http://ftp.ps.pl/pub/apache/hadoop/core/hadoop-1.1.2/hadoop-1.1.2.tar.gz",
    path => $path,
    unless => "ls /usr/local | grep hadoop",
    require => Package["openjdk-6-jdk"]
  }

  exec { "unpack_hadoop":
    command => "tar -xzf /tmp/hadoop.tar.gz -C /usr/local",
    path => $path,
    creates => "${hadoop_home}-1.1.2",
    require => Exec["download_hadoop"]
  }

  exec { "simplify_hadoop":
    command => "mv ${hadoop_home}-1.1.2 ${hadoop_home} && chown -R hduser:hadoop ${hadoop_home}",
    path => $path,
    creates => "${hadoop_home}",
    require => Exec["unpack_hadoop"]
  }

  file { "/etc/profile.d/hadoop_home.sh":
    source => "puppet:///modules/hadoop/hadoop_home.sh" 
  }

  exec { "create_hadoop_tmp_folder":
    command => "mkdir -p ${hadoop_tmp_parent_folder}",
    path => $path,
    creates => "${hadoop_tmp_parent_folder}"
  }

  file { "${hadoop_tmp_path}":
    ensure => directory,
    mode => 750,
    owner => hduser,
    group => hadoop,
    require => Exec["create_hadoop_tmp_folder"]
  }

  file {
    "${hadoop_home}/conf/hadoop-env.sh":
    source => "puppet:///modules/hadoop/hadoop-env.sh",
    mode => 644,
    owner => hduser,
    group => hadoop,
    require => Exec["simplify_hadoop"]
  }

  file {
    "${hadoop_home}/conf/core-site.xml":
    content => template("hadoop/core-site.xml.erb"),
    mode => 644,
    owner => hduser,
    group => hadoop,
    require => Exec["simplify_hadoop"]
   }
   
  file {
    "${hadoop_home}/conf/mapred-site.xml":
    content => template("hadoop/mapred-site.xml.erb"),
    mode => 644,
    owner => hduser,
    group => hadoop,
    require => Exec["simplify_hadoop"]
   }
   
   file {
    "${hadoop_home}/conf/hdfs-site.xml":
    content => template("hadoop/hdfs-site.xml.erb"),
    mode => 644,
    owner => hduser,
    group => hadoop,
    require => Exec["simplify_hadoop"]
   }
}
