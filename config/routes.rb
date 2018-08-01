RedmineApp::Application.routes.draw do
  get "env_auth/info", :to => "env_auth#info"
end
