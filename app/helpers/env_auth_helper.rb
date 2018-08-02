module EnvAuthHelper
  def remote_user
    #request.env["HTTP_X_REMOTE_USER"] = ""
    key = request.env[Setting.plugin_redmine_env_auth["env_variable_name"]]
    suffix = Setting.plugin_redmine_env_auth["remove_suffix"]
    unless suffix.empty? then key = key.chomp suffix end
    key
  end
end
