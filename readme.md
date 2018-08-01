# redmine_env_auth
this plugin allows to authenticate users using a variable in the request environment (set by the server or proxy server, in rails "request.env"). this variable can be custom named. one use case is log-in with single sign-on solutions (SSO) like ntlm/kerberos where the server (for example apache with mod_auth_kerberos) sets the request environment variable $REMOTE_USER to a username when a user has been authenticated.

# changelog
* 2018-08: completely revised, less code, added debugging features

# features
* automatically log-in users if a specific request environment variable is set, and log-out if it is unset
* option to allow conventional redmine logins for admins, specific users or everyone
* option to register users automatically if they are found using ldap
* "sign out" link hidden when autologin is active
* compatible with redmine 3

# installation
## download
dowload a [release](https://github.com/Intera/redmine_env_auth/releases) or a [zip file](https://github.com/Intera/redmine_env_auth/archive/master.zip) via github and unpack the archive.
alternatively you can clone the repository with "git clone https://github.com/Intera/redmine_env_auth.git"

## setup
move the "redmine_env_auth" directory from the download to your redmine installation directory under "plugins/", so that you have "plugins/redmine_env_auth". restart redmine. if the file system permissions are right, the plugin should now be installed. go into redmine under "Administration" "Plugins" to check that it is listed and eventually use the configure link to adjust settings of the plugin

# settings
|name|default|description|
|----|-------|-----------|
|enabled|true|enable or disable the plugin|
|name of request environment variable|REMOTE_USER||
|remove suffix||the given text will be removed from the end of the text in the environment variable|
|redmine user property|login|match local redmine users by login name or alternatively email address|
|allow other login|admins|this allows conventional logins|
|automatic registration with ldap check|false|if a matching local redmine user can not be found, try to find it in ldap and, if found, automatically create the user in redmine|

# debugging
* /env_auth/info displays the current name and value of the environment variable that is configured to be used
* messages with the debug levels debug, info and error are written into the redmine log {redmine_root}/log/{environment}.log. log levels are set in ``{redmine_root}/config/additional_environment.rb`` (might have to be created), for example with the line ``config.log_level = :debug``

if you are locked out because the allow other login setting is not set to "all" and the request environment variable isnt set correctly, you might want to reset the plugin settings to be able to log-in with the conventional redmine login. the plugin settings are stored in the database and the sql to delete them is ``delete from settings where name="plugin_redmine_env_auth";``. you might have to restart redmine afterwards

# possible enhancements
* drop previously created sessions if conventional login disabled

# copyright and license
originally based on code from adam lantos, [redmine_http_auth](https://github.com/AdamLantos/redmine_http_auth).
* copyright (c) 2010 niif institute and adam lantos, released under the mit license
* copyright (c) 2018 [intera](https://www.intera.de/) (mit license)
