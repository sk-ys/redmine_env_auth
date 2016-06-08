this plugin adds an optional http authentication method to redmine for authenticating with a value in the request environment (ENV, request.env), custom named, for example request_user. this can be used for login with ntlm (kerberos) when authentication is handled by a proxy server that sets the request environment variable (for example as mod_auth_kerberos does).

this version includes most fixes that were found in forks up to now

added features
* add a new feature and setting to automatically register users if they are found in ldap
* hide "sign out" when autologin is active
* add option that allows conventional redmine logins
* add a new setting to hide the menu entry for manual env auth login
* renamed plugin

# installation
use the following command in your redmine instance directory:

    ruby script/plugin install https://github.com/intera/redmine_env_auth.git

# settings
the behavior of this plugin can be customized through the 'settings' page in the
plugins menu. currently there are three options:

* enable / disable http authentication (default: enable)
* set the header / environment value to look for (default: remote_user)
* change local user lookup mode from login name to email address
  (default: login name)
* enable / disable automatic registration (default: disable), see below
* enable / disable the "keep session" behavior (default: disable), see below

# known issues
if you encounter "uninitialized constant rails::plugin::applicationcontroller"
exception with any redmine version prior to redmine-0.9, just rename your
app/controllers/application.rb to app/controllers/application_controller.rb.

# using lazy authentication
the env_authentication plugin provides a top menu link for lazy, user-requested
authentication purposes. this link points to the `/envauth-login` url. if you
want to enable both env_authentication and normal form-based logins, you need
to use this link to enforce container authentication.

however, many authentication mechanisms (namely apache httpd mod_auth_basic)
don't offer a way to do lazy authentication. if an url is not "enforced", the
authorization information (eg. remote_user) is not populated. thus, the session
synchronization code will invalidate user sessions outside the protected realm.

you can alter this behavior by switching on the "keep sessions" setting. but
please consider that this might be dangerous. do not use this feature if you
are implementing sso systems, you've been warned.

copyright (c) 2010 niif institute and adam lantos, released under the mit license
