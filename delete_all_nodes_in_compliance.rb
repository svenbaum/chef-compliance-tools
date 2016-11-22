#!/usr/bin/env ruby

# deletes all nodes in the compliance server 

require "awesome_print"

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "compliance_api"

# get environments
response = api_call('GET', "/owners/#{ComplianceConf.api_org}/envs")
envs = JSON.parse(response.body)

# array of nodes in compliance postgres database
allnodes = []

# iterate over all environments to get all nodes
envs.each { |e|
  response = api_call('GET', "/owners/#{ComplianceConf.api_org}/envs/#{e['id']}/nodes")
  allnodes += JSON.parse(response.body)
}

compliance_nodes = allnodes.compact
#ap compliance_nodes

# iterate over all nodes 
compliance_nodes.each { |i|
  i.each do |k,v|
    next unless (k =~ /id/)
    api_call('DELETE', "/owners/#{ComplianceConf.api_org}/envs/#{i["environment"]}/nodes/#{i["id"]}")
  end
}
ap "Removed: #{compliance_nodes.length} nodes in Compliance"

# delete all environments  
envs.each { |e|
  response = api_call('DELETE', "/owners/#{ComplianceConf.api_org}/envs/#{e['id']}")
}
ap "Removed: #{envs.length} environments in Compliance"

