require "redmine"

Redmine::Plugin.register :redmine_env_auth do
  name "request environment authentication"
  author "Adam Lantos (original Version); Intera GmbH (Extension)"
  author_url "http://github.com/AdamLantos/redmine_http_auth" if respond_to?(:author_url)
  url "http://github.com/intera/redmine_env_auth" if respond_to?(:url)
  description "a plugin for authentication based on variables in the request environment"
  version "0.4"

  Redmine::MenuManager.map :account_menu do |menu|
    menu.delete :logout
    menu.push :logout, :signout_path, :html => {:method => "post"}, :if => Proc.new {
      env_auth_enabled = Setting.plugin_redmine_env_auth["enable"] == "true"
      other_auth_enabled = Setting.plugin_redmine_env_auth["allow_other_login"] == "true"
      User.current.logged? && !(env_auth_enabled && !other_auth_enabled)
    }, :after => :my_account
  end

  settings :partial => "settings/redmine_env_auth_settings",
    :default => {
      "enable" => "true",
      "server_env_var" => "REMOTE_USER",
      "lookup_mode" => "login",
      "keep_sessions" => "false",
      "login_menu_entry" => "false",
      "allow_other_login" => "false",
      "ldap_checked_auto_registration" => "false"
    }
end

Rails.configuration.to_prepare do
  RedmineEnvAuth::EnvAuthPatch.install
end
