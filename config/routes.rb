RedmineApp::Application.routes.draw do
  get 'envauth-login', :to => 'welcome#index'
  get 'envauth-info', :to => 'main#info'
  get 'envauth-selfregister', :to => 'registration#register'
  post 'envauth-selfregister', :to => 'registration#register'
end
