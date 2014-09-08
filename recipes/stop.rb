node[:deploy].each do |application, deploy|
  execute "restart-sidekiq" do
    command %Q{
      echo "monit -g logvalet stop all" | at now
    }
  end
end