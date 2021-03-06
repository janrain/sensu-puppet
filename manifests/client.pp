define sensu::client(
                      $rabbitmq_password,
                      $rabbitmq_ssl_private_key = '',
                      $rabbitmq_ssl_cert_chain  = '',
                      $rabbitmq_port            = '5671',
                      $rabbitmq_host            = 'localhost',
                      $rabbitmq_user            = 'sensu',
                      $rabbitmq_vhost           = '/sensu',
                      $address                  = $ipaddress,
                      $subscriptions            = [],
                      $write_config             = true
                      ) {

  include sensu::package

  sensu::rabbitmq { 'client':
    ssl_cert_chain  => $rabbitmq_ssl_cert_chain,
    ssl_private_key => $rabbitmq_ssl_private_key,
    port            => $rabbitmq_port,
    host            => $rabbitmq_host,
    user            => $rabbitmq_user,
    vhost           => $rabbitmq_vhost,
    password        => $rabbitmq_password,
  }

  if $write_config == true {
    sensu_client_config { $::fqdn:
      client_name   => $name,
      address       => $address,
      subscriptions => $subscriptions,
    }
  }

  service { 'sensu-client':
    ensure  => running,
    enable  => true,
    provider => debian,
    require => [
      Sensu_rabbitmq_config[$::fqdn],
      Sensu_client_config[$::fqdn],
    ],
  }
}
