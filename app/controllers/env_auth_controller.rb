class EnvAuthController < ApplicationController
  helper EnvAuthHelper
  def info
    effective = remote_user
    variable_name = Setting.plugin_redmine_env_auth["env_variable_name"]
    original = request.env[variable_name]
    render :plain => "variable name: #{variable_name}, original value: #{original.inspect}, effective value: #{effective.inspect}"
  end
end
