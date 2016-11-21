#!/usr/bin/env ruby

# Module for api calls to the Compliance server 

require 'colorize' 
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

require 'chef_compliance_config'

def api_call(method, uri, body = nil)
  uri = "/api" + uri
  case method.upcase
  when "GET"
    request = Net::HTTP::Get.new(uri)
  when "POST"
    request = Net::HTTP::Post.new(uri)
  when "PATCH"
    request = Net::HTTP::Patch.new(uri)
  when "DELETE"
    request = Net::HTTP::Delete.new(uri)
  else
    puts "Invalid method #{method} for api_call\n".colorize(:light_red)
    exit 1
  end
  
  request.add_field('Content-Type', 'application/json')
  request.add_field('Authorization', "Bearer #{@api_token}") unless @api_token.nil?
  request.body = body unless body.nil?
  response = @http.request(request)
  if response.code != '200'
    puts "Failed #{method} to #{uri}, reason: #{response.body} code: #{response.code}\n".colorize(:light_red)
    exit 2
  end
  return response
end

uri = URI.parse(ComplianceConf.api_url)
@http = Net::HTTP.new(uri.host, uri.port)
@http.use_ssl = true
@http.verify_mode = OpenSSL::SSL::VERIFY_NONE

response = api_call('POST', '/login', { 'userid' => ComplianceConf.api_user, 'password' => ComplianceConf.api_pass }.to_json)
@api_token = response.body

def api_token() 
  return @api_token
end 

def http() 
  return @http
end 



