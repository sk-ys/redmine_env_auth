module RedmineEnvAuth
  module EnvAuthPatch
    def self.install
      ApplicationController.class_eval do
        include EnvAuthHelper

        def find_current_user_other_login
          # -> false/user
          allow_other_login = Setting.plugin_redmine_env_auth["allow_other_login"]
          if not ["admins", "users", "all", "none"].include? allow_other_login
            allow_other_login = "all"
          end
          allow_other_login = false if "none" == allow_other_login
          if "users" == allow_other_login
            allow_other_login_users = Setting.plugin_redmine_env_auth["allow_other_login_users"]
            allow_other_login_users = allow_other_login_users.split(",").map {|a| a.strip }
          end
          if allow_other_login
            user = find_current_user_without_envauth
            if user and user.is_a? User
              return user if ("all" == allow_other_login)
              return user if ("admins" == allow_other_login) and user.admin?
              return user if ("users" == allow_other_login) and allow_other_login_users.include?(user.login)
              false
            else
              user
            end
          end
        end

        def find_current_user_with_envauth
          plugin_disabled = Setting.plugin_redmine_env_auth["enabled"] != "true"
          if plugin_disabled then return find_current_user_without_envauth end
          user = find_current_user_other_login
          if user then
            logger.debug "redmine_env_auth: continuing active session for #{user.name}"
            return user
          end
          logger.debug "redmine_env_auth: trying to log in using environment variable"
          key = remote_user
          if !key or key.empty?
            logger.info "redmine_env_auth: environment variable is unset"
            return nil
          end
          logger.debug "redmine_env_auth: environment variable value is \"#{key}\""
          property = Setting.plugin_redmine_env_auth["redmine_user_property"]
          if "mail" == property
            user = User.active.find_by_mail key
          else
            user = User.active.find_by_login key
          end
          auto = "true" == Setting.plugin_redmine_env_auth["ldap_checked_auto_registration"]
          if (not user) and auto then user = register_if_exists_in_ldap key end
          if user and user.is_a? User
            logger.debug "redmine_env_auth: user found, start session"
            start_user_session user
            user.update_attribute(:last_login_on, Time.now)
            User.current = user
          else
            logger.debug "redmine_env_auth: redmine user #{key} not found using property #{property}"
            return nil
          end
        end

        def register_if_exists_in_ldap user_name
          # search all ldap sources for a user with the given name and if found,
          # create a user with that name in redmine.
          auth_sources = AuthSource.where :type => "AuthSourceLdap", :onthefly_register => true
          auth_sources.each do |auth_source|
            attrs = auth_source.get_attrs_for_env_auth user_name
            if attrs
              user = User.new attrs
              user.login = user_name
              user.language = Setting.default_language
              if user.save
                user.reload
              else
                logger.error "redmine_env_auth: user creation after ldap sync failed"
                nil
              end
            else
              logger.debug "redmine_env_auth: no user found via ldap"
              nil
            end
          end
        end

        ApplicationController.class_eval do
          # register find_current_user_with/without_envauth
          alias_method_chain :find_current_user, :envauth
        end
      end
      AuthSourceLdap.class_eval do
        def get_attrs_for_env_auth login
          return nil if login.blank?
          with_timeout do
            # password is irrelevant because there is no authentication
            attrs = get_user_dn login, ""
            if attrs && attrs[:dn]
              return attrs.except :dn
            end
          end
        rescue Net::LDAP::LdapError => e
          raise AuthSourceException.new e.message
        end
      end
    end
  end
end
