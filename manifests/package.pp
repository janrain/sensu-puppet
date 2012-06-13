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
		mode   => '0644',
	}
	file { '/etc/sensu/plugins/check_disk.rb':
		ensure => present,
		source => 'puppet:///modules/sensu/plugins/check_disk.rb',
		owner  => root,
		group  => root,
		mode   => '0755',
		require => File['/etc/sensu/plugins'],
	}
	sensu_clean_config { $::fqdn: }
}
