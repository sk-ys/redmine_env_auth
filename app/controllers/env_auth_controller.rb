class EnvAuthController < ApplicationController
  def info
    effective = remote_user
    variable_name = Setting.plugin_redmine_env_auth["env_variable_name"]
    original = request.env[variable_name]
    keys = request.env.keys.sort.select {|a|
      ["action_dispatch.", "action_controller.", "rack.", "puma."].none? {|b| a.start_with?(b)}
    }.join("\n  ")
    text = [
      "variable name: #{variable_name}",
      "original value: #{original.inspect}",
      "effective value: #{effective.inspect}",
      "available variables:\n  #{keys}"
    ].join("\n")
    render :plain => text
  end
end
