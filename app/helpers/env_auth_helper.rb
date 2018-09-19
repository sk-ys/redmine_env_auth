module EnvAuthHelper
  def remote_user
    #request.env["HTTP_X_REMOTE_USER"] = ""
    key = request.env[Setting.plugin_redmine_env_auth["env_variable_name"]]
    return nil unless key
    suffix = Setting.plugin_redmine_env_auth["remove_suffix"]
    if suffix.is_a?(String) and not suffix.empty?
      key.chomp suffix
    else
      key
    end
  end
end
