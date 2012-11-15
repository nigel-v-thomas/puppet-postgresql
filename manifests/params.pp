class postgresql::params {
  $locale = 'en_US.UTF-8'
  case $::operatingsystem {
    /(Ubuntu|Debian)/: {
      $version = '9.1'
      $client_package = 'postgresql-client'
      $server_package = 'postgresql'
      $listen_address = 'localhost'
      $standard_conforming_strings = 'on'
      $shared_buffers = '24MB'
      $checkpoint_segments = 3
      $maintenanceworkmem = '16MB'
      $tcpip_socket = true
      $max_connections = 100
      $checkpoint_timeout = '5min'
      $datestyle = 'iso, mdy'
      $autovacuum = off
      $port = 5432
    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
