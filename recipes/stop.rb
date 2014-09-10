node[:deploy].each do |application, deploy|
  execute "stop-logvalet" do
    command %Q{
      echo "monit -g logvalet stop all" | at now
    }
  end
end