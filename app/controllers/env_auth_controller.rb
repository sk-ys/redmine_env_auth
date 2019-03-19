class EnvAuthController < ApplicationController
  helper EnvAuthHelper
  def info
    name = Setting.plugin_redmine_env_auth["env_variable_name"]
    render :plain => "variable name: #{name}, value: #{remote_user.inspect}"
  end
end
