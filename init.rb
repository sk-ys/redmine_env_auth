require "redmine"

Redmine::Plugin.register :redmine_env_auth do
  name "request environment authentication"
  author "Intera GmbH"
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
      "enabled" => "false",
      "server_env_var" => "REMOTE_USER",
      "postfix" => "",
      "lookup_mode" => "login",
      "allow_other_login" => "admins",
      "allow_other_login_users" => "",
      "ldap_checked_auto_registration" => "false"
    }
end

Rails.configuration.to_prepare do
  RedmineEnvAuth::EnvAuthPatch.install
end
