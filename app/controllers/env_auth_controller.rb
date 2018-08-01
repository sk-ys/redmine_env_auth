class EnvAuthController < ApplicationController
  include EnvAuthHelper
  skip_before_filter :user_setup, :check_if_login_required
  helper :env_auth

  def info
    name = Setting.plugin_redmine_env_auth["env_variable_name"]
    render :text => "variable name: #{name}<br/>value: #{remote_user.inspect}"
  end
end
