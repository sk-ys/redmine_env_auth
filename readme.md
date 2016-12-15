# redmine_env_auth
this plugin adds an optional authentication method to redmine to authenticate from a variable in the request environment (set by the server or proxy server, in rails "request.env"). this variable can be custom named. one use case is enabling login with single sign-on solutions (SSO) like ntlm/kerberos when a kerberos enabled server (for example apache with mod_auth_kerberos) sets the request environment variable $REMOTE_USER when users are logged in.

# features
* automatically log-in users if a specific request environment variable is set, and log-out if it is unset
* optionally register users automatically if they are found via redmines ldap connection
* "sign out" is hidden when autologin is active
* optional menu entry that allows conventional redmine logins
* compatible with redmine 3

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
|name of request environment variable|REMOTE_USER|may be set to a user name or email address|
|Domain postfix| empty |If your krb5 or something is configured so that variable is returned to the user in the form lastname@DOMAIN.LOCAL in this variable, you must specify the DOMAIN.LOCAL Then users will normally log in on the value of the lastname|
|user lookup field|login|match local redmine users by login name or alternatively email address|
|menu entry|false|enable menu entry for manual login|
|allow other login|false|this allows conventional logins and also makes conventional logins have preference|
|automatic registration via ldap|false|if a local redmine user does not exist, look it up in ldap and, if found, automatically register the user in redmine|
|keep login sessions without env authentication or when env authentication is lost|false|one use case for this is to disable authentication in the web server for some urls|

# copyright and license
originally created by adam lantos as [redmine_http_auth](https://github.com/AdamLantos/redmine_http_auth).
this version includes most fixes that were found in forks of redmine_http_auth up to this point and additional features.

copyright (c) 2010 niif institute and adam lantos, released under the mit license.

extended by [intera](https://www.intera.de/) (same license).
