#!/usr/bin/env ruby

require 'dotenv'
Dotenv.load

# Chef Credentials
class ChefConf   
  class << self
    attr_accessor :server_url, :client_key, :client_name
  end
  @server_url = 'https://api.opscode.com/organizations/burberry'
  @client_key = File.expand_path("../.chef/#{ENV['CHEF_USER']}.pem", __dir__)
  @client_name = "#{ENV['CHEF_USER']}"
end

# Compliance Credentials
class ComplianceConf
  class << self
    attr_accessor :api_url, :api_user, :api_pass, :api_org
  end
  @api_url = 'https://bb-dev-chef-compliance-01.eu-west.burberry.corp'
  @api_user = ENV['COMPLIANCE_USER']
  @api_pass = ENV['COMPLIANCE_PASS']
  @api_org = 'burberry'
end


