# redmine_env_auth
this plugin adds an optional http authentication method to redmine to authenticate with a variable in the request environment (rails request.env, set by the server or proxy server). this variable can be custom named. one use case is login with single-sign on solutions (SSO) like ntlm/kerberos when a kerberos enabled proxy server (for example mod_auth_kerberos) sets the request environment variable $REMOTE_USER when for logged in users.

# features
* automatically log-in users if a specific request environment variable is set, and log-out if it is unset
* optionally register users automatically if they are found via redmines ldap connection
* "sign out" is hidden when autologin is active
* optional menu entry that allows conventional redmine logins
* compatible with redmine 3

this version includes most fixes that were found in forks up to this point.

# installation
## download
dowload a [release](https://github.com/Intera/redmine_env_auth/releases) or a [zip file](https://github.com/Intera/redmine_env_auth/archive/master.zip) via github and unpack the archive.
alternatively you can clone the repository with "git clone https://github.com/Intera/redmine_env_auth.git".

## setup
move the "redmine_env_auth" directory from the download to your redmine installation directory under "plugins/", so that you have "plugins/redmine_env_auth".
if the file system permissions are right, the plugin should now be installed. go into redmine under "Administration" "Plugins" to check that it is listed and eventually use the configure link to adjust settings of the plugin.

# settings
|name|default|description|
|----|-------|-----------|
|enable env authentication|true|enable or disable the plugin|
|name of request environment variable|REMOTE_USER|name of the request environment variable that may be set to a username when a user visits the site|
|user lookup field|login|match users by login name or alternatively email address from the request environment variable|
|menu entry|false|enable menu entry for manual login|
|allow other login|false|this allows conventional logins and also makes conventional logins have preference|
|automatic registration via ldap|false|if a username or email given in the request environment variable does not exist, look it up in ldap and automatically register the user if found|
|keep login sessions without env authentication or when env authentication is lost|false||

# copyright and license
originally created by adam lantos as [redmine_http_auth](https://github.com/AdamLantos/redmine_http_auth).
    copyright (c) 2010 niif institute and adam lantos, released under the mit license
extended by [intera](https://www.intera.de/) (same license).
