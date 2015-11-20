require 'aws-sdk'
require 'open-uri'

namespace :load do
  task :defaults do
    set :ec2_ports, [22]
    set :ec2_access_key_id, nil
    set :ec2_secret_access_key, nil
    set :ec2_security_group, nil
    set :ec2_region, nil
    set :ec2_config, 'config/aws.yml'
  end
end

namespace :ec2 do
  desc "Open ports in security group for your current ip address"
  task :allow_ip do
    warn "Allowing ssh access for #{remote_ip}"
    ports.each do |port|
      begin
        security_group.authorize_ingress(:tcp, port, remote_ip+'/32')
      rescue AWS::EC2::Errors::InvalidPermission::Duplicate
      end
    end
  end

  desc "Close ports in security group for your current ip address"
  task :revoke_ip do
    warn "Revoking ssh access for #{remote_ip} on ports #{ports}"
    ports.each do |port|
      begin
        security_group.revoke_ingress(:tcp, port, remote_ip+'/32')
      rescue AWS::EC2::Errors::InvalidPermission::NotFound
      end
    end
  end

  task :cleanup_ips do
    desc "Close ports in security group for all ip addresses except yours"
    security_group.ingress_ip_permissions.each do |permission|
      if ports_in_range?(permission.port_range)
        permission.ip_ranges.each do |ip|
          unless ip.include?(remote_ip)
            warn "Revoking ssh access for #{ip} on ports #{permission.port_range}"
            security_group.revoke_ingress(:tcp, permission.port_range, ip)
          end
        end
      end
    end
  end

  task :init_aws do
    # try and load config from yml file
    config_location = File.expand_path(fetch(:ec2_config), Dir.pwd)
    if fetch(:ec2_config) && File.exists?(config_location)
      file = YAML.load_file(config_location)
      config = file[fetch(:rails_env).to_s]
      if config
        ['access_key_id', 'secret_access_key', 'region'].each do |key|
          sym = "ec2_#{key}".to_sym
          set sym, config[key] if config[key] && fetch(sym).blank?
        end
      end
    end

    AWS.config(
      access_key_id: fetch(:ec2_access_key_id),
      secret_access_key: fetch(:ec2_secret_access_key),
      region: fetch(:ec2_region)
    )
  end

  before 'ec2:allow_ip',    'ec2:init_aws'
  before 'ec2:revoke_ip',   'ec2:init_aws'
  before 'ec2:cleanup_ips', 'ec2:init_aws'

  def security_group
    @security_group ||= AWS::EC2::SecurityGroup.new fetch(:ec2_security_group)
  end

  def remote_ip
    @remote_ip ||= open('http://whatismyip.akamai.com').read
  end

  def ports
    @ports ||= fetch(:ec2_ports)
  end

  def ports_in_range?(port_range)
    ports.each do |port|
      return true if port_range.include? port
    end
    return false
  end
end
