class EnvAuthController < ApplicationController
  include EnvAuthHelper
  skip_before_filter :user_setup, :check_if_login_required
  helper :env_auth

  def info
    render :text => remote_user
  end
end
