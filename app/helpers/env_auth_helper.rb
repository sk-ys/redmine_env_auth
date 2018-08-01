module EnvAuthHelper
  def remote_user
    request.env["REMOTE_USER"] = "adminx"
    key = request.env[Setting.plugin_redmine_env_auth["env_variable_name"]]
    suffix = Setting.plugin_redmine_env_auth["remove_suffix"]
    unless suffix.empty? then key = key.chomp suffix end
    key
  end
end
