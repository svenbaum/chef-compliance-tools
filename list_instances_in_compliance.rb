#!/usr/bin/env ruby

# list all instances in Compliance server 

require "awesome_print"
require 'pp'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "compliance_api"

# get environments
response = api_call('GET', "/owners/#{ComplianceConf.api_org}/envs")
envs = JSON.parse(response.body)

# array of instances in compliance postgres database
allnodes = []

# iterate over all environments to get all nodes
envs.each { |e|
  response = api_call('GET', "/owners/#{ComplianceConf.api_org}/envs/#{e['id']}/nodes")
  allnodes += JSON.parse(response.body)
}

compliance_nodes = allnodes.compact
#ap compliance_nodes

compliance_ips = []
compliance_ids = []
comp_ip_name = {}
compliance_nodes.each { |i|
  i.each do |k,v|
    next unless (k =~ /id/)
    compliance_ids.push(v)
  end
  i.each do |k,v|
    next unless (k =~ /hostname/)
    ip = v.to_s
    compliance_ips.push(ip)
    comp_ip_name[ip] = i.to_h
  end
}
compliance_ids = compliance_ids.sort

puts "" if (compliance_ids.length > 0)

ap compliance_ids

ap "Total: #{compliance_ids.length} instances in Compliance"  

#pp compliance_ids
#pp compliance_ips 

