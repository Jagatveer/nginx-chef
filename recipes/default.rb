#
# Cookbook Name:: nginx
# Recipe:: default
#
# Author: Jagatveer Singh
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'nginx::install'

template node['nginx']['prefix'] + '/conf/nginx.conf' do
  source 'nginx.conf.erb'
  mode '644'
  notifies :reload, 'service[nginx]'
end

include_recipe 'nginx::error_pages'

service 'nginx' do
  action [:enable, :start]
end
