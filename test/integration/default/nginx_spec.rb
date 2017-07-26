require 'serverspec'

set :backend, :exec

packages = [
  'pcre-devel',
  'openssl',
  'openssl-devel']

packages.each do|p|
  describe package(p) do
    it { should be_installed }
  end
end

describe service('nginx') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe port(8080) do
  it { should be_listening }
end
