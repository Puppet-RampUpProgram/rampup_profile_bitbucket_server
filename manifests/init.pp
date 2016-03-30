# bitbucket profile based on thewired/bitbucket
class rampup_profile_bitbucket_server (
  $bitbucket_server_version = '4.4.1',
  $bitbucket_dbuser         = 'bitbucket',
  $bitbucket_dbpassword     = 'password',
) {

  #The bitbucket module uses archive or staging module
  #which requires unzip but doesn't seem to install it
  package { 'unzip':
    ensure => present,
  }

  package { 'git' :
    ensure => present,
  }

  class { 'java' :
    package => 'java-1.8.0-openjdk-devel',
  } ->

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.4',
  } ->
  class { 'postgresql::server': } ->

  #class { 'bitbucket::gc': }
  #class { 'bitbucket::facts': }

  postgresql::server::db { 'bitbucket':
    user     => $bitbucket_dbuser,
    password => postgresql_password($bitbucket_dbuser, $bitbucket_dbpassword),
  } ->

  class { 'bitbucket':
    javahome    => '/etc/alternatives/java_sdk',
    #dev.mode grants a 24-hour license for testing
    java_opts   => '-Datlassian.dev.mode=true',
    version     => $bitbucket_server_version,
    require     => [ Package['git', 'unzip'] ],
    dbuser      => $bitbucket_dbuser,
    dbpassword  => $bitbucket_dbpassword,
  }

}
