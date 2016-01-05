RedmineApp::Application.routes.draw do
  get 'envauth-login', :to => 'welcome#index'
  get 'envauth-selfregister', :to => 'registration#autoregistration_form'
end
