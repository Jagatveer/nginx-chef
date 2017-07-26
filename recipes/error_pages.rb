#
# Cookbook Name:: nginx
# Recipe:: error_pages
#
# Author: Jagatveer Singh
#

directory node['nginx']['error_pages'] do
   owner node['nginx']['user']
   group node['nginx']['group']
   recursive true
   action :create
end

%w(404.html 500.html Maintenance.html).each do |file_name|
  cookbook_file "#{node['nginx']['error_pages']}/#{file_name}" do
    source file_name
  end
end
