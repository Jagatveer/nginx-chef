# Default values for installing nginx

default['nginx']['version'] = '1.8.0'
default['nginx']['is_ldap'] = false
default['nginx']['openssl'] = 'openssl-1.0.2g'
default['nginx']['pid_path'] = '/var/run/nginx.pid'
default['nginx']['prefix'] = '/usr/local/nginx'
default['nginx']['config_params'] = "--without-mail_pop3_module --user=nobody --group=nobody --with-http_ssl_module --with-openssl=#{Chef::Config['file_cache_path']}/#{nginx['openssl']} --without-mail_imap_module --without-mail_smtp_module --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_stub_status_module --with-pcre --with-http_spdy_module"
default['nginx']['port'] = '80'
default['nginx']['user'] = 'nobody'
default['nginx']['group'] = 'nobody'
default['nginx']['doc_root'] = '/var/www/html'
default['nginx']['vhostconf_dir'] = 'vhosts.d'
default['nginx']['disabled_dir'] = 'disabled.d'
default['nginx']['proxyconf_dir'] = 'proxies.d'
default['nginx']['force_compile'] = false
default['nginx']['nginx_checksum'] = '23cca1239990c818d8f6da118320c4979aadf5386deda691b1b7c2c96b9df3d5'
default['nginx']['openssl_checksum'] = 'b784b1b3907ce39abf4098702dade6365522a253ad1552e267a9a0e89594aa33'
default['nginx']['error_pages'] = '/var/www/html/error_pages'
default['nginx']['limit_conn'] = 10
