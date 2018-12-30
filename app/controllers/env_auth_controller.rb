class EnvAuthController < ApplicationController
  include EnvAuthHelper

  skip_method = self.respond_to?(:skip_before_filter) ? :skip_before_filter : :skip_before_action

  send(skip_method, :user_setup, :check_if_login_required)
  helper :env_auth

  def info
    name = Setting.plugin_redmine_env_auth["env_variable_name"]
    render :text => "variable name: #{name}<br/>value: #{remote_user.inspect}"
  end
end
