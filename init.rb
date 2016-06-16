require 'redmine'

Rails.logger.info 'Starting Redmine Env Auth plugin for RedMine'

Redmine::Plugin.register :redmine_env_auth do
  name 'environment authentication plugin'
  author 'Adam Lantos'
  author_url 'http://github.com/AdamLantos/redmine_http_auth' if respond_to?(:author_url)
  url 'http://github.com/intera/redmine_env_auth' if respond_to?(:url)
  description 'a plugin for authentication based on variables in the request environment'
  version '0.3.2'
  menu :account_menu, :login_envauth, "./envauth-login",
    :before => :login, :caption => :login_envauth_title,
    :if => Proc.new {
    User.current.anonymous? && Setting.plugin_redmine_env_auth['enable'] == 'true' && Setting.plugin_redmine_env_auth['login_menu_entry'] == 'true' }

  Redmine::MenuManager.map :account_menu do |menu|
    menu.delete :logout
    menu.push :logout, :signout_path, :html => {:method => 'post'}, :if => Proc.new {
      # if a user is logged in with env_auth is stored in the session, but the session is not easily accessible here.
      # that is why it does not work well if the environment variable is not set (which enables the login form).
      env_auth_enabled = Setting.plugin_redmine_env_auth['enable'] == 'true'
      other_auth_enabled = Setting.plugin_redmine_env_auth['allow_other_login'] == 'true'
      User.current.logged? && !(env_auth_enabled && !other_auth_enabled)
    }, :after => :my_account
  end

  settings :partial => 'settings/redmine_env_auth_settings',
    :default => {
      'enable' => 'true',
      'server_env_var' => 'REMOTE_USER',
      'lookup_mode' => 'login',
      'keep_sessions' => 'false',
      'login_menu_entry' => 'false',
      'allow_other_login' => 'false',
      'ldap_checked_auto_registration' => 'false'
    }
end

Rails.configuration.to_prepare do
  RedmineEnvAuth::EnvAuthPatch.install
end
