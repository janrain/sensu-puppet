class sensu::package {

	apt::source { "sensuapp":
		location => "http://repos.sensuapp.org/apt",
		release => "sensu",
		repos => "main",
		include_src => false,
	}

	exec {
		'sensu-aptkey':
			command   => '/usr/bin/curl -s http://repos.sensuapp.org/apt/pubkey.gpg \
			| sudo apt-key add -',
			unless    => '/usr/bin/apt-key list | /bin/grep 7580C77F 2>/dev/null',
			cwd       => '/tmp',
			before	  => Package['sensu'],
			notify    => Exec['sensu-update'],
			logoutput => on_failure;
		'sensu-update':
			command     => 'apt-get update',
		   	path        => '/usr/bin',
			before	    => Package['sensu'],
		    	refreshonly => true;
	}
	package { 'sensu':
		ensure   => latest,
		provider => 'apt',
	}
	package { 'sensu-plugin':
                ensure 	 => latest,
                provider => 'gem',
        }
	file { '/etc/sensu/plugins':
		ensure => directory,
		owner  => root,
		group  => root,
		mode   => '0755',
	}
	file { '/etc/sensu/plugins/check_disk.rb':
		ensure => present,
		source => 'puppet:///modules/sensu/plugins/check_disk.rb',
		owner  => root,
		group  => root,
		mode   => '0755',
		require => File['/etc/sensu/plugins'],
	}
	file { '/etc/sensu/plugins/check-mem.sh':
		ensure => present,
		source => 'puppet:///modules/sensu/plugins/check-mem.sh',
		owner  => root,
		group  => root,
		mode   => '0755',
		require => File['/etc/sensu/plugins'],
	}
	file { '/etc/sensu/plugins/check-haproxy.rb':
	  ensure   => present,
	  source   => 'puppet:///modules/sensu/plugins/check-haproxy.rb',
    owner    => root,
    group    => root,
    mode     => '0755',
    require  => File['/etc/sensu/plugins'],
  }
  #this is because haproxy package conflicts with the apt package!
  exec { "gem-package-haproxy":
    path       => '/usr/bin/gem',
    command    => 'gem install --version 0.0.4',
    unless     => "gem list --local | grep 'haproxy.*0.0.4'"
  }
  file { '/etc/init/sensu-client.conf':
    ensure => absent,
  }
	sensu_clean_config { $::fqdn: }
}
