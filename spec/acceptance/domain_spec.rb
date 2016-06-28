require 'spec_helper_acceptance'

describe 'orawls::domain' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        exec { 'fetch_wls1036_generic.jar':
          command => '/usr/bin/wget -O /tmp/wls1036_generic.jar http://pulp.cegeka.be/rpm/wls1036_generic.jar',
          creates => '/tmp/wls1036_generic.jar'
        }
        package { ['java-1.7.0-openjdk','wget']:
          ensure => present
        }
        include orawls::urandomfix
        class { 'orawls::weblogic': 
          version             => 1036,
          filename            => 'wls1036_generic.jar',
          jdk_home_dir        => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/jre',
          oracle_base_home_dir => '/u01/weblogic',
          weblogic_home_dir   => '/u01/weblogic/11g/wlserver_10.3',
          middleware_home_dir => '/u01/weblogic/11g',
          wls_domains_dir     => '/u01/weblogic/11g/domains',
          wls_apps_dir        => '/u01/weblogic/11g/applications',
          os_user             => 'root',
          os_group            => 'root',
          download_dir        => '/tmp',
          source              => '/tmp',
          require             => [Package['java-1.7.0-openjdk'],Exec['fetch_wls1036_generic.jar']]
        }
        orawls::domain { 'wls1036':
          version             => 1036,
          weblogic_home_dir   => '/u01/weblogic/11g/wlserver_10.3',
          middleware_home_dir => '/u01/weblogic/11g',
          jdk_home_dir        => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/jre',
          domain_template     => 'standard',
          domain_name         => 'TESTdomain',
          development_mode    => false,
          adminserver_name    => 'AdminServer',
          adminserver_address => 'localhost',
          adminserver_port    => 7011,
          nodemanager_secure_listener => true,
          nodemanager_port    => 5556,
          weblogic_user       => 'weblogic',
          weblogic_password   => 'weblogic',
          os_user             => 'root',
          os_group            => 'root',
          log_dir             => '/var/log',
          download_dir        => '/tmp',
          log_output          => true,
          require             => Class['orawls::weblogic']
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/u01/weblogic/11g/wlserver_10.3' do
      it { is_expected.to be_directory }
    end

  end
end

