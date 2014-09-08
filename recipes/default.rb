node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  Chef::Log.info("Configuring logvalet for application #{application}")

  settings = node[:logvalet]
  settings = settings[application] if settings
  workers = (settings && settings[:workers]) ? settings[:workers] : 1

  template "#{deploy[:deploy_to]}/shared/scripts/logvalet" do
    mode '0755'
    owner deploy[:user]
    group deploy[:group]
    source "logvalet.service.erb"
    variables(:deploy => deploy, :application => application)
  end

  template "/etc/monit.d/logvalet.monitrc" do
    owner "root"
    group "root"
    mode '0644'
    source "logvalet.monitrc.erb"
    variables({ :application => application, :deploy => deploy, :workers => workers })
  end

  execute "ensure-logvalet-is-setup-with-monit" do
    command %Q{
      monit reload
    }
  end

  execute "restart-sidekiq" do
    command %Q{
      echo "sleep 20 && monit -g logvalet restart all" | at now
    }
  end
end