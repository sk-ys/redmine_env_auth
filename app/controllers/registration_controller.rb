class RegistrationController < ApplicationController
  unloadable
  skip_before_filter :user_setup, :check_if_login_required
  include EnvAuthHelper
  helper :env_auth
  before_filter :autoregistration_enabled, :remote_user_set

  def autoregistration_form
    @user = User.new :language => Setting.default_language
    set_default_attributes @user
  end

  def register
    # not implemented, previous version did not work. intended to offer a form to request additional required user information and create a user.
    # careful when implementing - it should not be possible for any user to be able to create user accounts arbitrarily.
  end

  def autoregistration_enabled
    unless Setting.plugin_redmine_env_auth['auto_registration'] == "true"
      flash[:error] = l :error_autoregistration_disabled
      redirect_to home_url
    end
  end

  def remote_user_set
    remote_user.nil?
  end
end
