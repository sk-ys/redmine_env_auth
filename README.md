Extended version
=======

* add a new setting to hide the menu entry
* hide "sign out" when autologin is active
* add option that allows conventional redmine logins
* renamed plugin

this plugin allows automatic login by a value in the request environment, custom named, for example named `REQUEST_USER.` this can be used for login with ntlm (kerberos) when authentication is handled by another server that sets a request environment variable (for example `mod_auth_kerberos`).

This version includes most fixes that were found in forks up to now. the autoregistration feature has been deactivated because it did not seem to work.
Compared to version found at `https://github.com/Intera/redmine_env_auth`, it is compatible with Redmine 3.x

----

HTTP Authentication plugin for Redmine
=======

This plugin enables an optional HTTP authentication method in the Redmine
project management tool.

If the `REMOTE_USER` server environment variable is set, an attempt is
made to look up the matching local user account and log in. An attempt is made
to synchronize redmine session with the container managed authentication session,
but this can be switched off.

This module does not disable the form-based login unless HTTP authentication
credentials are available, in which case the username from the environment
will override the form-based login.


Installation
=======

Use the following command in your Redmine instance directory:

# ruby script/plugin install `https://github.com/milinnovations/redmine_env_auth.git`


Settings
=======

The behavior of this plugin can be customized through the 'settings' page in the
plugins menu. Currently there are three options:

- enable / disable HTTP Authentication (default: enable)
- set the header / environment value to look for (default: REMOTE_USER)
- change local user lookup mode from login name to email address
  (default: login name)
- enable / disable automatic registration (default: disable), see below
- enable / disable the "keep session" behavior (default: disable), see below


Known issues
=======

If you encounter "uninitialized constant Rails::Plugin::ApplicationController"
exception with any Redmine version prior to Redmine-0.9, just rename your
`app/controllers/application.rb` to `app/controllers/application_controller.rb`.

Automatic registration of user accounts
=======

If a user doesn't exist in the redmine local database, the `env_authentication`
plugin can automatically create an account for them. This automatic registration
currently presents a form to the user where additional attributes (like email
address, first name or last name) should be entered.

The plugin currently doesn't handle automatic attribute transformation from the
authentication environment (eg. Shibboleth session), but it does enforce the
lookup attribute matching with the environment.

Automatically registered accounts don't have associated passwords, but the
user can change their password via the common password change form.


Session synchronization
=======

When using container managed authentication (like SSO systems), one needs to
ensure, that the currently logged-on user is the same which initiated the session.
Additionally, there is a need to offer logout functionality to the end user.

By default, the `env_authentication` plugin synchronizes the container managed
authentication session to the redmine session. This means that if the underlying
session changes or ends, the redmine session changes and ends as well.


Using lazy authentication
=======

The `env_authentication` plugin provides a top menu link for lazy, user-requested
authentication purposes. This link points to the `/envauth-login` URL. If you
want to enable both `env_authentication` and normal form-based logins, you need
to use this link to enforce container authentication.

However, many authentication mechanisms (namely apache httpd `mod_auth_basic`)
don't offer a way to do lazy authentication. If an URL is not "enforced", the
authorization information (eg. `REMOTE_USER`) is not populated. Thus, the session
synchronization code will invalidate user sessions outside the protected realm.

You can alter this behavior by switching on the "keep sessions" setting. But
please consider that this might be dangerous. Do not use this feature if you
are implementing SSO systems, you've been warned.

Redmine behind (Apache) proxy
=======

If you have a web server that takes care of authentization, you have to tell 
it to pass the information on, so the server that really runs Redmine (e.g. 
`unicorn` or `passenger`) knows the username from the proxy.

Typically, you include this in the Apache config (see also `http://serverfault.com/questions/693583/how-to-get-remote-user-via-apache-proxy`):


    RewriteCond %{LA-U:REMOTE_USER} (.+)
    RewriteRule . - [E=RU:%1,L]
    RequestHeader add X-Forwarded-User %{RU}e

Then, you have to swap `REMOTE_USER` in settings for `HTTP_X_FORWARDED_USER`.

Next, if you do HTTPS on your proxy, you want Redmine to know that settings so it makes links to itself starting with `https://` rather than `http://`.
To do so, you need to include this line in your Apache config (see also `http://www.redmine.org/issues/1145`):

    RequestHeader add X_FORWARDED_PROTO "https"

Planned features
=======

- option to disable form-based login for users when the plugin is activated
- integration with the custom features of various SSO systems (eg. Shibboleth)


Copyright (c) 2010 NIIF Institute and Adam Lantos, released under the MIT license
