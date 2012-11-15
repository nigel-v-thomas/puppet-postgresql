class postgresql::server (
  $server_package = $postgresql::params::server_package,
  $locale = $postgresql::params::locale,
  $version = $postgresql::params::version,
  $listen = $postgresql::params::listen_address,
  $port = $postgresql::params::port,
  $acl = [],
  $standard_conforming_strings = $postgresql::params::standard_conforming_strings,
  $shared_buffers = $postgresql::params::shared_buffers,
  $checkpoint_segments = $postgresql::params::checkpoint_segments,
  $maintenanceworkmem = $postgresql::params::maintenanceworkmem,
  $tcpip_socket = $postgresql::params::tcpip_socket,
  $max_connections = $postgresql::params::max_connections,
  $checkpoint_timeout = $postgresql::params::checkpoint_timeout,
  $datestyle = $postgresql::params::datestyle,
  $autovacuum = $postgresql::params::autovacuum,
) inherits postgresql::params {

  
  case $version {
    '8.4': {
      $postgressqlServerVersion = "postgresql-$version"
      $postgressqlServiceVersion = "postgresql-$version"
 
      # postgres 8.4 and ubuntu only bug fix... http://askubuntu.com/questions/44373/how-to-fix-postgresql-installation
      file { "postgresql-server-os-kernel-environment-tweak":
        name    => "/etc/sysctl.d/30-postgresql-tweak.conf",
        ensure  => present,
        content => template('postgresql/postgresql-shm.conf.erb'),
        mode    => '0644',
        before =>  Package[$postgressqlServerVersion],
      }
        
      exec { "postgresql-server-os-kernel-environment-refresh":
        command => ["sysctl -p"],
        path => ["/bin", "/usr/bin", "/usr/sbin", "/sbin"],
        onlyif => "test `sysctl -a | grep -c kernel.shmmax` = 0",
        require => File["postgresql-server-os-kernel-environment-tweak"],
      }
    }
    default: {
        $postgressqlServerVersion = "postgresql-server-$version"
        $postgressqlServiceVersion = "postgresql"
    }
  }
  
  package { $postgressqlServerVersion:
    name    => sprintf("%s-%s", $server_package, $version),
    ensure  => present,
  }

  service { "postgresql":
    name        => $postgressqlServiceVersion,
    enable      => true,
    ensure      => running,
    hasstatus   => false,
    hasrestart  => true,
    provider    => 'debian',
    require => Package[$postgressqlServerVersion],
    subscribe   => Package[$postgressqlServerVersion],
  }

  file { "postgresql-server-config-$version":
    name    => "/etc/postgresql/$version/main/postgresql.conf",
    ensure  => present,
    content => template('postgresql/postgresql.conf.erb'),
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0644',
    require => Package[$postgressqlServerVersion],
    notify  => Service["postgresql"],
  }

  file { "postgresql-server-hba-config-$version":
    name    => "/etc/postgresql/$version/main/pg_hba.conf",
    ensure  => present,
    content => template('postgresql/pg_hba.conf.erb'),
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0640',
    require => Package[$postgressqlServerVersion],
    notify  => Service["postgresql"],
  }

}
