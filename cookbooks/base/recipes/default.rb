include_recipe "build-essential"
require_recipe "postfix"
require_recipe "ssh::server"
include_recipe "ssh_keys"

if node[:role] and node[:roles].has_key?(node[:role])
  
  role[:groups].each do |group_name|
  
    group group_name.to_s do
      gid node[:groups][group_name][:gid]
    end

    users = node[:users].find_all { |u| u.last[:group] == group_name }

    users.each do |u, config|
      user u do
        comment config[:comment]
        uid config[:uid]
        gid config[:group].to_s
        home "/home/#{u}"
        shell "/bin/bash"
        password config[:password]
        supports :manage_home => true
      end

      directory "/home/#{u}/.ssh" do
        action :create
        owner u
        group config[:group].to_s
        mode 0700
      end
      
      add_keys u do
        conf config
      end
    end
  end

  directory "/u" do
    action :create
    owner "root"
    group "admin"
    mode 0775
  end

  
  

  require_recipe "sudo"
else
  Chef::Log.warn "The node requires a role, one of: #{node[:roles].keys.join(',')}"
end