module RedmineEnvAuth
  module AccountControllerPatch
    def self.included(base)
      base.class_eval do
        # We're substituting the original function since redirect_to can only be called once and we need to change the target page
	      def logout
          logout_user
          if Setting.plugin_redmine_env_auth['enable'] == "true"
            redirect_to signin_url
          else
            redirect_to home_url
          end
        end
      end
    end
  end
end
