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
          # first redmine's normal way of finding current user
          plugin_disabled = Setting.plugin_redmine_env_auth["enable"] != "true"
          allow_other_login = Setting.plugin_redmine_env_auth["allow_other_login"]
          if not ["admins", "users", "all", "none"].include?(allow_other_login)
            allow_other_login = "all"
          end
          allow_other_login = false if "none" == allow_other_login
          if "users" == allow_other_login
            allow_other_login_users = Setting.plugin_redmine_env_auth["allow_other_login_users"] || ""
            allow_other_login_users = allow_other_login_users.split(",").map {|a| a.strip }
          end
          if plugin_disabled or allow_other_login
            user = find_current_user_without_envauth
            return user if plugin_disabled
            if !user.nil?
              return user if ("all" == allow_other_login)
              return user if ("admin" == allow_other_login) and user.admin?
              return user if ("users" == allow_other_login) and allow_other_login.include?(user.name)
            end
          end
          logger.debug "request_env_auth: trying to log in via environment variable"
          username = remote_user
          if !username or username.empty?
            logger.info "request_env_auth: environment variable is empty"
            return nil
          end
          logger.debug "request_env_auth: environment variable value is \"#{username}\""
          return user unless session_changed? user, username
          try_login username
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

        def try_login username
          # username is true at this point.
          # find user by login name or email address
          postfix = Setting.plugin_redmine_env_auth["server_domain_postfix"] || ""
          unless postfix.empty? then username = username.chomp postfix end
          if use_email?
            user = User.active.find_by_mail username
          else
            user = User.active.find_by_login username
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
            # login and return user if user was found
            do_login user
          end
        end

        def used_env_authentication?
          session[:env_authentication] == true
        end

        def use_email?
          Setting.plugin_redmine_env_auth["lookup_mode"] == "mail"
        end

        def session_changed?(user, username)
          if user.nil?
            true
          else
            use_email? ? user.mail.casecmp(username) != 0 : user.login.casecmp(username) != 0
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
