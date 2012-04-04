#
# Cookbook Name:: demo_app_server
# Recipe:: default
#

include_recipe "passenger_apache2::mod_rails"

app = data_bag_item("apps", "quoter")
app_name = app["id"]
app_config = app["common"].merge(app["environments"][node.chef_environment])

web_app app_name do
  docroot "#{app_config["deploy_path"]}/current/public"
  template "vhost.conf.erb"
  server_name "#{node.name}.#{app_config["app_domain"]}"
  server_aliases [node[:ec2][:public_hostname], node[:fqdn]]
  rails_env app_config["rails_env"]
end

directory "#{app_config["deploy_path"]}" do
  owner app_config["deploy_owner"]
  group app_config["deploy_group"]
  mode "0755"
  recursive true
end

directory "#{app_config["deploy_path"]}/shared" do
  owner app_config["deploy_owner"]
  group app_config["deploy_group"]
  mode "0755"
  recursive true
end

%w{assets bundle log pids system}.each do |dir|
  directory "#{app_config["deploy_path"]}/shared/#{dir}" do
    owner app_config["deploy_owner"]
    group app_config["deploy_group"]
    mode "0755"
    recursive true
  end
end

deploy_key_path = "#{app_config["deploy_path"]}/id_deploy"

ruby_block "write_deploy_key" do
  block do
    File.open(deploy_key_path, "w") { |f| f.write(app_config["deploy_key"]) }
  end
  not_if do
    File.exists?(deploy_key_path)
  end
end

file deploy_key_path do
  owner app_config["deploy_owner"]
  group app_config["deploy_group"]
  mode "0600"
end

template "#{app_config["deploy_path"]}/deploy-ssh-wrapper" do
  source "deploy-ssh-wrapper.erb"
  owner app_config["deploy_owner"]
  group app_config["deploy_group"]
  mode "0755"
  variables :app_name => app_name, :key_path => deploy_key_path
end

shell_env = { "RAILS_ENV" => app_config["rails_env"] }

deploy app_config["deploy_path"] do
  environment shell_env
  symlink_before_migrate({})
  repo app_config["repository"]
  user app_config["deploy_owner"]
  group app_config["deploy_group"]
  revision app_config["deploy_revision"]
  restart_command "touch tmp/restart.txt"
  ssh_wrapper "#{app_config["deploy_path"]}/deploy-ssh-wrapper"
  before_symlink do
    link "#{release_path}/public/assets" do
      to "#{app_config["deploy_path"]}/shared/assets"
    end
    link "#{release_path}/vendor/bundle" do
      to "#{app_config["deploy_path"]}/shared/bundle"
    end
    rbenv_script "install bundle" do
      code "bundle install --deployment --without test development"
      rbenv_version node[:rbenv][:global]
      environment shell_env
      cwd release_path
    end
    rbenv_script "create db" do
      code "bundle exec rake db:create"
      rbenv_version node[:rbenv][:global]
      environment shell_env
      cwd release_path
    end
    rbenv_script "migrate db" do
      code "bundle exec rake db:migrate"
      rbenv_version node[:rbenv][:global]
      environment shell_env
      cwd release_path
    end
    rbenv_script "precompile assets" do
      code "bundle exec rake assets:precompile"
      rbenv_version node[:rbenv][:global]
      environment shell_env
      cwd release_path
    end
  end
end
