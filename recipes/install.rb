#
# Cookbook Name:: nginx
# Recipe:: install
#
# Author: Jagatveer Singh
#

%w(pcre-devel openssl openssl-devel).each do |pkg|
  package pkg do
    action :install
  end
end

remote_file Chef::Config['file_cache_path'] + "/nginx-#{node['nginx']['version']}.tar.gz" do
  source "http://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
  checksum "#{node['nginx']['nginx_checksum']}"
end

remote_file Chef::Config['file_cache_path'] + "/#{node['nginx']['openssl']}.tar.gz" do
  source "http://www.openssl.org/source/#{node['nginx']['openssl']}.tar.gz"
  checksum "#{node['nginx']['openssl_checksum']}"
  notifies :run, 'execute[unzip openssl]', :immediately
end

if node['nginx']['is_ldap']

  git "#{Chef::Config[:file_cache_path]}/nginx-auth-ldap" do
    repository 'https://github.com/kvspb/nginx-auth-ldap.git'
    revision 'master'
    action :sync
  end

  %w(openldap openldap-devel).each do |pkg|
    package pkg do
      action :install
    end
  end

  node.default['nginx']['config_params'] = node['nginx']['config_params'] + " --add-module=#{Chef::Config[:file_cache_path]}/nginx-auth-ldap"

end

execute 'unzip openssl' do
  command <<-EOF
            set -e
            cd "#{Chef::Config['file_cache_path']}"
            tar zxf "#{node['nginx']['openssl']}.tar.gz"
        EOF
  action :nothing
end

isupgrade = true

if File.exist?('/etc/init.d/nginx')
  current_version = Mixlib::ShellOut.new("#{node['nginx']['prefix']}/sbin/nginx -v 2>&1 | grep -Po '(\\d+\\.\\d+\\.\\d+)'").run_command.stdout
  current_configration = Mixlib::ShellOut.new("#{node['nginx']['prefix']}/sbin/nginx -V 2>&1 | grep configure").run_command.stdout
  new_configration = "configure arguments: #{node['nginx']['config_params']} --user=#{node['nginx']['user']} --group=#{node['nginx']['group']}"
  if Gem::Version.new(current_version) >= Gem::Version.new(node['nginx']['version'])
    if (current_configration.strip == new_configration.strip)
      isupgrade = false
    else
      isupgrade = true
    end
  end

  (isupgrade = true) if (node['nginx']['force_compile'] == true)
end

execute 'install_nginx' do
  command <<-EOF
        set -e
            cd "#{Chef::Config['file_cache_path']}"
            tar zxf nginx-#{node['nginx']['version']}.tar.gz
            cd "#{Chef::Config['file_cache_path']}/nginx-#{node['nginx']['version']}"
            ./configure #{node['nginx']['config_params']} --user=#{node['nginx']['user']} --group=#{node['nginx']['group']}
            make
            make install
        EOF
  only_if { isupgrade == true }
end

group node['nginx']['group'] do
  action 'create'
end

user node['nginx']['user'] do
  gid node['nginx']['group']
  shell '/bin/nologin'
  system true
  action 'create'
end

template '/etc/init.d/nginx' do
  source 'nginx.init.erb'
  mode '755'
end

# Setup directory structure
directory node['nginx']['doc_root'] do
  owner node['nginx']['user']
  group node['nginx']['group']
  action :create
  recursive true
end

directory node['nginx']['prefix'] + '/conf/' + node['nginx']['vhostconf_dir'] do
  action :create
  recursive true
end

directory node['nginx']['prefix'] + '/conf/' + node['nginx']['disabled_dir'] do
  action :create
  recursive true
end

directory node['nginx']['prefix'] + '/conf/' + node['nginx']['proxyconf_dir'] do
  action :create
  recursive true
end

directory node['nginx']['prefix'] + '/conf/certs' do
  action :create
  recursive true
end

cookbook_file node['nginx']['doc_root'] + '/index.html' do
  source 'index.html'
end

link '/etc/nginx' do
  to '/usr/local/nginx/conf'
end

link '/var/log/nginx' do
  to '/usr/local/nginx/logs'
end
