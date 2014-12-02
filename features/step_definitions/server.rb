Given(/^the server for "(.*?)" app is ready$/) do |app_name|
  raise "Server for app #{ app_name } not started" unless @running_apps.keys.include?(app_name)
end
