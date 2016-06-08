module RedmineEnvAuth
  module EnvAuthPatch
    unloadable
    def self.install
      AuthSourceLdap.class_eval do
        def get_attrs_for_env_auth login
          return nil if login.blank?
          with_timeout do
            # password is irrelevant because there is no authentication.
            attrs = get_user_dn login, ""
            if attrs && attrs[:dn]
              return attrs.except :dn
            end
          end
        rescue Net::LDAP::LdapError => e
          raise AuthSourceException.new e.message
        end
      end
      ApplicationController.class_eval do
        include EnvAuthHelper
        def find_current_user_with_envauth
          if Setting.plugin_redmine_env_auth["allow_other_login"] == "true"
            # this allows conventional logins and also makes conventional logins have preference
            user = find_current_user_without_envauth
            return user unless user.nil? or user.anonymous?
          end

          #first proceed with redmine's version of finding current user
          user = find_current_user_without_envauth
          #if the env_auth is disabled in config, return the user
          return user unless Setting.plugin_redmine_env_auth["enable"] == "true"

          remote_username = remote_user
          if remote_username.nil?
            #do not touch user, if he didn't use env authentication to log in
            #or if the keep_sessions configuration directive is set
            if !used_env_authentication? || Setting.plugin_redmine_env_auth["keep_sessions"] == "true"
              return user
            end
            #log out previously authenticated user
            reset_session
            return nil
          end
          #return if the user has not been changed behind the session
          return user unless session_changed? user, remote_username
          #log out current logged in user
          reset_session
          try_login remote_username
        end

        def register_if_exists_in_ldap login
          # search all relevant ldap sources and create a user with name "login" if it has been found.
          auth_sources = AuthSource.where :type => "AuthSourceLdap", :onthefly_register => true
          auth_sources.each do |auth_source|
            attrs = auth_source.get_attrs_for_env_auth login
            if attrs
              user = User.new attrs
              user.login = login
              user.language = Setting.default_language
              user.save ? user.reload : nil
            end
          end
        end

        def try_login remote_username
          #remote_username is true at this point.
          #find user by login name or email address
          if use_email?
            user = User.active.find_by_mail remote_username
          else
            user = User.active.find_by_login remote_username
          end
          if user.nil?
            if Setting.plugin_redmine_env_auth["auto_registration"] == "true"
              redirect_to envauthselfregister_url
              return nil
            elsif Setting.plugin_redmine_env_auth["ldap_checked_auto_registration"] == "true"
              user = register_if_exists_in_ldap remote_user
              if user
                do_login(user) if user
              end
            else
              flash[:error] = l :error_unknown_user
              return nil
            end
          else
            #login and return user if user was found
            do_login user
          end
        end

        def used_env_authentication?
          session[:env_authentication] == true
        end

        def use_email?
          Setting.plugin_redmine_env_auth["lookup_mode"] == "mail"
        end

        def session_changed?(user, remote_username)
          if user.nil?
            true
          else
            use_email? ? user.mail.casecmp(remote_username) != 0 : user.login.casecmp(remote_username) != 0
          end
        end

        def do_login(user)
          if (user && user.is_a?(User))
            start_user_session(user)
            session[:env_authentication] = true
            user.update_attribute(:last_login_on, Time.now)
            User.current = user
          else
            return nil
          end
        end
        ApplicationController.class_eval do
          alias_method_chain :find_current_user, :envauth
        end
      end
    end
  end
end
