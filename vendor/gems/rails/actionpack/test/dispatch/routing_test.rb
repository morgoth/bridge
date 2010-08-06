require 'abstract_unit'
require 'controller/fake_controllers'

class TestRoutingMapper < ActionDispatch::IntegrationTest
  SprocketsApp = lambda { |env|
    [200, {"Content-Type" => "text/html"}, ["javascripts"]]
  }

  class IpRestrictor
    def self.matches?(request)
      request.ip =~ /192\.168\.1\.1\d\d/
    end
  end

  stub_controllers do |routes|
    Routes = routes
    Routes.draw do
      default_url_options :host => "rubyonrails.org"
      resources_path_names :correlation_indexes => "info_about_correlation_indexes"

      controller :sessions do
        get  'login' => :new
        post 'login' => :create
        delete 'logout' => :destroy
      end

      resource :session do
        get :create
        post :reset

        resource :info

        member do
          get :crush
        end
      end

      scope "bookmark", :controller => "bookmarks", :as => :bookmark do
        get  :new, :path => "build"
        post :create, :path => "create", :as => ""
        put  :update
        get  "remove", :action => :destroy, :as => :remove
      end

      match 'account/logout' => redirect("/logout"), :as => :logout_redirect
      match 'account/login', :to => redirect("/login")

      constraints(lambda { |req| true }) do
        match 'account/overview'
      end

      match '/account/nested/overview'
      match 'sign_in' => "sessions#new"

      match 'account/modulo/:name', :to => redirect("/%{name}s")
      match 'account/proc/:name', :to => redirect {|params| "/#{params[:name].pluralize}" }
      match 'account/proc_req' => redirect {|params, req| "/#{req.method}" }

      match 'account/google' => redirect('http://www.google.com/')

      match 'openid/login', :via => [:get, :post], :to => "openid#login"

      controller(:global) do
        get   'global/hide_notice'
        match 'global/export',      :to => :export, :as => :export_request
        match '/export/:id/:file',  :to => :export, :as => :export_download, :constraints => { :file => /.*/ }
        match 'global/:action'
      end

      match "/local/:action", :controller => "local"

      match "/projects/status(.:format)"

      constraints(:ip => /192\.168\.1\.\d\d\d/) do
        get 'admin' => "queenbee#index"
      end

      constraints ::TestRoutingMapper::IpRestrictor do
        get 'admin/accounts' => "queenbee#accounts"
      end

      get 'admin/passwords' => "queenbee#passwords", :constraints => ::TestRoutingMapper::IpRestrictor

      scope 'pt', :as => 'pt' do
        resources :projects, :path_names => { :edit => 'editar', :new => 'novo' }, :path => 'projetos' do
          post :preview, :on => :new
          put :close, :on => :member, :path => 'fechar'
          get :open, :on => :new, :path => 'abrir'
        end
        resource  :admin, :path_names => { :new => 'novo', :activate => 'ativar' }, :path => 'administrador' do
          post :preview, :on => :new
          put :activate, :on => :member
        end
        resources :products, :path_names => { :new => 'novo' } do
          new do
            post :preview
          end
        end
      end

      resources :projects, :controller => :project do
        resources :involvements, :attachments
        get :correlation_indexes, :on => :collection

        resources :participants do
          put :update_all, :on => :collection
        end

        resources :companies do
          resources :people
          resource  :avatar, :controller => :avatar
        end

        resources :images, :as => :funny_images do
          post :revise, :on => :member
        end

        resource :manager, :as => :super_manager do
          post :fire
        end

        resources :people do
          nested do
            scope "/:access_token" do
              resource :avatar
            end
          end

          member do
            get  :some_path_with_name
            put  :accessible_projects
            post :resend, :generate_new_password
          end
        end

        resources :posts do
          get  :archive, :toggle_view, :on => :collection
          post :preview, :on => :member

          resource :subscription

          resources :comments do
            post :preview, :on => :collection
          end
        end
      end

      resources :replies do
        new do
          post :preview
        end

        member do
          put :answer, :to => :mark_as_answer
          delete :answer, :to => :unmark_as_answer
        end
      end

      resources :posts, :only => [:index, :show] do
        resources :comments, :except => :destroy
      end

      resource  :past, :only => :destroy
      resource  :present, :only => :update
      resource  :future, :only => :create
      resources :relationships, :only => [:create, :destroy]
      resources :friendships,   :only => [:update]

      shallow do
        namespace :api do
          resources :teams do
            resources :players
            resource :captain
          end
        end
      end

      resources :threads, :shallow => true do
        resource :owner
        resources :messages do
          resources :comments do
            member do
              post :preview
            end
          end
        end
      end

      resources :sheep

      resources :clients do
        namespace :google do
          resource :account do
            namespace :secret do
              resource :info
            end
          end
        end
      end

      resources :customers do
        get "recent" => "customers#recent", :as => :recent, :on => :collection
        get "profile" => "customers#profile", :as => :profile, :on => :member
        post "preview" => "customers#preview", :as => :preview, :on => :new
        resource :avatar do
          get "thumbnail(.:format)" => "avatars#thumbnail", :as => :thumbnail, :on => :member
        end
        resources :invoices do
          get "outstanding" => "invoices#outstanding", :as => :outstanding, :on => :collection
          get "overdue", :to => :overdue, :on => :collection
          get "print" => "invoices#print", :as => :print, :on => :member
          post "preview" => "invoices#preview", :as => :preview, :on => :new
        end
        resources :notes, :shallow => true do
          get "preview" => "notes#preview", :as => :preview, :on => :new
          get "print" => "notes#print", :as => :print, :on => :member
        end
      end

      namespace :api do
        resources :customers do
          get "recent" => "customers#recent", :as => :recent, :on => :collection
          get "profile" => "customers#profile", :as => :profile, :on => :member
          post "preview" => "customers#preview", :as => :preview, :on => :new
        end
        scope(':version', :version => /.+/) do
          resources :users, :id => /.+?/, :format => /json|xml/
        end
      end

      match 'sprockets.js' => ::TestRoutingMapper::SprocketsApp

      match 'people/:id/update', :to => 'people#update', :as => :update_person
      match '/projects/:project_id/people/:id/update', :to => 'people#update', :as => :update_project_person

      # misc
      match 'articles/:year/:month/:day/:title', :to => "articles#show", :as => :article

      # default params
      match 'inline_pages/(:id)', :to => 'pages#show', :id => 'home'
      match 'default_pages/(:id)', :to => 'pages#show', :defaults => { :id => 'home' }
      defaults :id => 'home' do
        match 'scoped_pages/(:id)', :to => 'pages#show'
      end

      namespace :account do
        match 'shorthand'
        match 'description', :to => :description, :as => "description"
        match ':action/callback', :action => /twitter|github/, :to => "callbacks", :as => :callback
        resource :subscription, :credit, :credit_card

        root :to => "account#index"

        namespace :admin do
          resource :subscription
        end
      end

      namespace :forum do
        resources :products, :path => '' do
          resources :questions
        end
      end

      namespace :users, :path => 'usuarios' do
        root :to => 'home#index'
      end

      controller :articles do
        scope '/articles', :as => 'article' do
          scope :path => '/:title', :title => /[a-z]+/, :as => :with_title do
            match '/:id', :to => :with_id, :as => ""
          end
        end
      end

      scope ':access_token', :constraints => { :access_token => /\w{5,5}/ } do
        resources :rooms
      end

      match '/info' => 'projects#info', :as => 'info'

      namespace :admin do
        scope '(:locale)', :locale => /en|pl/ do
          resources :descriptions
        end
      end

      scope '(:locale)', :locale => /en|pl/ do
        resources :descriptions
        root :to => 'projects#index'
      end

      scope :only => [:index, :show] do
        resources :products, :constraints => { :id => /\d{4}/ } do
          root :to => "products#root"
          get :favorite, :on => :collection
          resources :images
        end
        resource :account
      end

      resource :dashboard, :constraints => { :ip => /192\.168\.1\.\d{1,3}/ }

      resource :token, :module => :api
      scope :module => :api do
        resources :errors, :shallow => true do
          resources :notices
        end
      end

      scope :path => 'api' do
        resource :me
        match '/' => 'mes#index'
      end

      get "(/:username)/followers" => "followers#index"
      get "/groups(/user/:username)" => "groups#index"
      get "(/user/:username)/photos" => "photos#index"

      scope '(groups)' do
        scope '(discussions)' do
          resources :messages
        end
      end

      match "whatever/:controller(/:action(/:id))", :id => /\d+/

      resource :profile do
        get :settings

        new do
          post :preview
        end
      end

      resources :content

      scope :constraints => { :id => /\d+/ } do
        get '/tickets', :to => 'tickets#index', :as => :tickets
      end

      scope :constraints => { :id => /\d{4}/ } do
        resources :movies do
          resources :reviews
          resource :trailer
        end
      end

      namespace :private do
        root :to => redirect('/private/index')
        match "index", :to => 'private#index'
      end

      scope :only => [:index, :show] do
        namespace :only do
          resources :clubs do
            resources :players
            resource  :chairman
          end
        end
      end

      scope :except => [:new, :create, :edit, :update, :destroy] do
        namespace :except do
          resources :clubs do
            resources :players
            resource  :chairman
          end
        end
      end

      scope :only => :show do
        namespace :only do
          resources :sectors, :only => :index do
            resources :companies do
              scope :only => :index do
                resources :divisions
              end
              scope :except => [:show, :update, :destroy] do
                resources :departments
              end
            end
            resource  :leader
            resources :managers, :except => [:show, :update, :destroy]
          end
        end
      end

      scope :except => :index do
        namespace :except do
          resources :sectors, :except => [:show, :update, :destroy] do
            resources :companies do
              scope :except => [:show, :update, :destroy] do
                resources :divisions
              end
              scope :only => :index do
                resources :departments
              end
            end
            resource  :leader
            resources :managers, :only => :index
          end
        end
      end

      match '/:locale/*file.:format', :to => 'files#show', :file => /path\/to\/existing\/file/
    end
  end

  class TestAltApp < ActionController::IntegrationTest
    class AltRequest
      def initialize(env)
        @env = env
      end

      def path_info
        "/"
      end

      def request_method
        "GET"
      end

      def x_header
        @env["HTTP_X_HEADER"] || ""
      end
    end

    class XHeader
      def call(env)
        [200, {"Content-Type" => "text/html"}, ["XHeader"]]
      end
    end

    class AltApp
      def call(env)
        [200, {"Content-Type" => "text/html"}, ["Alternative App"]]
      end
    end

    AltRoutes = ActionDispatch::Routing::RouteSet.new(AltRequest)
    AltRoutes.draw do
      get "/" => TestRoutingMapper::TestAltApp::XHeader.new, :constraints => {:x_header => /HEADER/}
      get "/" => TestRoutingMapper::TestAltApp::AltApp.new
    end

    def app
      AltRoutes
    end

    def test_alt_request_without_header
      get "/"
      assert_equal "Alternative App", @response.body
    end

    def test_alt_request_with_matched_header
      get "/", {}, "HTTP_X_HEADER" => "HEADER"
      assert_equal "XHeader", @response.body
    end

    def test_alt_request_with_unmatched_header
      get "/", {}, "HTTP_X_HEADER" => "NON_MATCH"
      assert_equal "Alternative App", @response.body
    end
  end

  def app
    Routes
  end

  include Routes.url_helpers

  def test_logout
    with_test_routes do
      delete '/logout'
      assert_equal 'sessions#destroy', @response.body

      assert_equal '/logout', logout_path
      assert_equal '/logout', url_for(:controller => 'sessions', :action => 'destroy', :only_path => true)
    end
  end

  def test_login
    with_test_routes do
      get '/login'
      assert_equal 'sessions#new', @response.body
      assert_equal '/login', login_path

      post '/login'
      assert_equal 'sessions#create', @response.body

      assert_equal '/login', url_for(:controller => 'sessions', :action => 'create', :only_path => true)
      assert_equal '/login', url_for(:controller => 'sessions', :action => 'new', :only_path => true)

      assert_equal 'http://rubyonrails.org/login', Routes.url_for(:controller => 'sessions', :action => 'create')
      assert_equal 'http://rubyonrails.org/login', Routes.url_helpers.login_url
    end
  end

  def test_login_redirect
    with_test_routes do
      get '/account/login'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com/login', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_logout_redirect_without_to
    with_test_routes do
      assert_equal '/account/logout', logout_redirect_path
      get '/account/logout'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com/logout', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_namespace_redirect
    with_test_routes do
      get '/private'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com/private/index', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_namespace_with_controller_segment
    assert_raise(ArgumentError) do
      self.class.stub_controllers do |routes|
        routes.draw do
          namespace :admin do
            match '/:controller(/:action(/:id(.:format)))'
          end
        end
      end
    end
  end

  def test_session_singleton_resource
    with_test_routes do
      get '/session'
      assert_equal 'sessions#create', @response.body
      assert_equal '/session', session_path

      post '/session'
      assert_equal 'sessions#create', @response.body

      put '/session'
      assert_equal 'sessions#update', @response.body

      delete '/session'
      assert_equal 'sessions#destroy', @response.body

      get '/session/new'
      assert_equal 'sessions#new', @response.body
      assert_equal '/session/new', new_session_path

      get '/session/edit'
      assert_equal 'sessions#edit', @response.body
      assert_equal '/session/edit', edit_session_path

      post '/session/reset'
      assert_equal 'sessions#reset', @response.body
      assert_equal '/session/reset', reset_session_path
    end
  end

  def test_session_info_nested_singleton_resource
    with_test_routes do
      get '/session/info'
      assert_equal 'infos#show', @response.body
      assert_equal '/session/info', session_info_path
    end
  end

  def test_member_on_resource
    with_test_routes do
      get '/session/crush'
      assert_equal 'sessions#crush', @response.body
      assert_equal '/session/crush', crush_session_path
    end
  end

  def test_redirect_modulo
    with_test_routes do
      get '/account/modulo/name'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com/names', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_redirect_proc
    with_test_routes do
      get '/account/proc/person'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com/people', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_redirect_proc_with_request
    with_test_routes do
      get '/account/proc_req'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com/GET', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_openid
    with_test_routes do
      get '/openid/login'
      assert_equal 'openid#login', @response.body

      post '/openid/login'
      assert_equal 'openid#login', @response.body
    end
  end

  def test_bookmarks
    with_test_routes do
      get '/bookmark/build'
      assert_equal 'bookmarks#new', @response.body
      assert_equal '/bookmark/build', new_bookmark_path

      post '/bookmark/create'
      assert_equal 'bookmarks#create', @response.body
      assert_equal '/bookmark/create', bookmark_path

      put '/bookmark'
      assert_equal 'bookmarks#update', @response.body
      assert_equal '/bookmark', update_bookmark_path

      get '/bookmark/remove'
      assert_equal 'bookmarks#destroy', @response.body
      assert_equal '/bookmark/remove', bookmark_remove_path
    end
  end

  def test_admin
    with_test_routes do
      get '/admin', {}, {'REMOTE_ADDR' => '192.168.1.100'}
      assert_equal 'queenbee#index', @response.body

      get '/admin', {}, {'REMOTE_ADDR' => '10.0.0.100'}
      assert_equal 'pass', @response.headers['X-Cascade']

      get '/admin/accounts', {}, {'REMOTE_ADDR' => '192.168.1.100'}
      assert_equal 'queenbee#accounts', @response.body

      get '/admin/accounts', {}, {'REMOTE_ADDR' => '10.0.0.100'}
      assert_equal 'pass', @response.headers['X-Cascade']

      get '/admin/passwords', {}, {'REMOTE_ADDR' => '192.168.1.100'}
      assert_equal 'queenbee#passwords', @response.body

      get '/admin/passwords', {}, {'REMOTE_ADDR' => '10.0.0.100'}
      assert_equal 'pass', @response.headers['X-Cascade']
    end
  end

  def test_global
    with_test_routes do
      get '/global/dashboard'
      assert_equal 'global#dashboard', @response.body

      get '/global/export'
      assert_equal 'global#export', @response.body

      get '/global/hide_notice'
      assert_equal 'global#hide_notice', @response.body

      get '/export/123/foo.txt'
      assert_equal 'global#export', @response.body

      assert_equal '/global/export', export_request_path
      assert_equal '/global/hide_notice', global_hide_notice_path
      assert_equal '/export/123/foo.txt', export_download_path(:id => 123, :file => 'foo.txt')
    end
  end

  def test_local
    with_test_routes do
      get '/local/dashboard'
      assert_equal 'local#dashboard', @response.body
    end
  end

  def test_projects_status
    with_test_routes do
      assert_equal '/projects/status', url_for(:controller => 'projects', :action => 'status', :only_path => true)
      assert_equal '/projects/status.json', url_for(:controller => 'projects', :action => 'status', :format => 'json', :only_path => true)
    end
  end

  def test_projects
    with_test_routes do
      get '/projects'
      assert_equal 'project#index', @response.body
      assert_equal '/projects', projects_path

      post '/projects'
      assert_equal 'project#create', @response.body

      get '/projects.xml'
      assert_equal 'project#index', @response.body
      assert_equal '/projects.xml', projects_path(:format => 'xml')

      get '/projects/new'
      assert_equal 'project#new', @response.body
      assert_equal '/projects/new', new_project_path

      get '/projects/new.xml'
      assert_equal 'project#new', @response.body
      assert_equal '/projects/new.xml', new_project_path(:format => 'xml')

      get '/projects/1'
      assert_equal 'project#show', @response.body
      assert_equal '/projects/1', project_path(:id => '1')

      get '/projects/1.xml'
      assert_equal 'project#show', @response.body
      assert_equal '/projects/1.xml', project_path(:id => '1', :format => 'xml')

      get '/projects/1/edit'
      assert_equal 'project#edit', @response.body
      assert_equal '/projects/1/edit', edit_project_path(:id => '1')
    end
  end

  def test_projects_involvements
    with_test_routes do
      get '/projects/1/involvements'
      assert_equal 'involvements#index', @response.body
      assert_equal '/projects/1/involvements', project_involvements_path(:project_id => '1')

      get '/projects/1/involvements/new'
      assert_equal 'involvements#new', @response.body
      assert_equal '/projects/1/involvements/new', new_project_involvement_path(:project_id => '1')

      get '/projects/1/involvements/1'
      assert_equal 'involvements#show', @response.body
      assert_equal '/projects/1/involvements/1', project_involvement_path(:project_id => '1', :id => '1')

      put '/projects/1/involvements/1'
      assert_equal 'involvements#update', @response.body

      delete '/projects/1/involvements/1'
      assert_equal 'involvements#destroy', @response.body

      get '/projects/1/involvements/1/edit'
      assert_equal 'involvements#edit', @response.body
      assert_equal '/projects/1/involvements/1/edit', edit_project_involvement_path(:project_id => '1', :id => '1')
    end
  end

  def test_projects_attachments
    with_test_routes do
      get '/projects/1/attachments'
      assert_equal 'attachments#index', @response.body
      assert_equal '/projects/1/attachments', project_attachments_path(:project_id => '1')
    end
  end

  def test_projects_participants
    with_test_routes do
      get '/projects/1/participants'
      assert_equal 'participants#index', @response.body
      assert_equal '/projects/1/participants', project_participants_path(:project_id => '1')

      put '/projects/1/participants/update_all'
      assert_equal 'participants#update_all', @response.body
      assert_equal '/projects/1/participants/update_all', update_all_project_participants_path(:project_id => '1')
    end
  end

  def test_projects_companies
    with_test_routes do
      get '/projects/1/companies'
      assert_equal 'companies#index', @response.body
      assert_equal '/projects/1/companies', project_companies_path(:project_id => '1')

      get '/projects/1/companies/1/people'
      assert_equal 'people#index', @response.body
      assert_equal '/projects/1/companies/1/people', project_company_people_path(:project_id => '1', :company_id => '1')

      get '/projects/1/companies/1/avatar'
      assert_equal 'avatar#show', @response.body
      assert_equal '/projects/1/companies/1/avatar', project_company_avatar_path(:project_id => '1', :company_id => '1')
    end
  end

  def test_project_manager
    with_test_routes do
      get '/projects/1/manager'
      assert_equal 'managers#show', @response.body
      assert_equal '/projects/1/manager', project_super_manager_path(:project_id => '1')

      get '/projects/1/manager/new'
      assert_equal 'managers#new', @response.body
      assert_equal '/projects/1/manager/new', new_project_super_manager_path(:project_id => '1')

      post '/projects/1/manager/fire'
      assert_equal 'managers#fire', @response.body
      assert_equal '/projects/1/manager/fire', fire_project_super_manager_path(:project_id => '1')
    end
  end

  def test_project_images
    with_test_routes do
      get '/projects/1/images'
      assert_equal 'images#index', @response.body
      assert_equal '/projects/1/images', project_funny_images_path(:project_id => '1')

      get '/projects/1/images/new'
      assert_equal 'images#new', @response.body
      assert_equal '/projects/1/images/new', new_project_funny_image_path(:project_id => '1')

      post '/projects/1/images/1/revise'
      assert_equal 'images#revise', @response.body
      assert_equal '/projects/1/images/1/revise', revise_project_funny_image_path(:project_id => '1', :id => '1')
    end
  end

  def test_projects_people
    with_test_routes do
      get '/projects/1/people'
      assert_equal 'people#index', @response.body
      assert_equal '/projects/1/people', project_people_path(:project_id => '1')

      get '/projects/1/people/1'
      assert_equal 'people#show', @response.body
      assert_equal '/projects/1/people/1', project_person_path(:project_id => '1', :id => '1')

      get '/projects/1/people/1/7a2dec8/avatar'
      assert_equal 'avatars#show', @response.body
      assert_equal '/projects/1/people/1/7a2dec8/avatar', project_person_avatar_path(:project_id => '1', :person_id => '1', :access_token => '7a2dec8')

      put '/projects/1/people/1/accessible_projects'
      assert_equal 'people#accessible_projects', @response.body
      assert_equal '/projects/1/people/1/accessible_projects', accessible_projects_project_person_path(:project_id => '1', :id => '1')

      post '/projects/1/people/1/resend'
      assert_equal 'people#resend', @response.body
      assert_equal '/projects/1/people/1/resend', resend_project_person_path(:project_id => '1', :id => '1')

      post '/projects/1/people/1/generate_new_password'
      assert_equal 'people#generate_new_password', @response.body
      assert_equal '/projects/1/people/1/generate_new_password', generate_new_password_project_person_path(:project_id => '1', :id => '1')
    end
  end

  def test_projects_with_resources_path_names
    with_test_routes do
      get '/projects/info_about_correlation_indexes'
      assert_equal 'project#correlation_indexes', @response.body
      assert_equal '/projects/info_about_correlation_indexes', correlation_indexes_projects_path
    end
  end

  def test_projects_posts
    with_test_routes do
      get '/projects/1/posts'
      assert_equal 'posts#index', @response.body
      assert_equal '/projects/1/posts', project_posts_path(:project_id => '1')

      get '/projects/1/posts/archive'
      assert_equal 'posts#archive', @response.body
      assert_equal '/projects/1/posts/archive', archive_project_posts_path(:project_id => '1')

      get '/projects/1/posts/toggle_view'
      assert_equal 'posts#toggle_view', @response.body
      assert_equal '/projects/1/posts/toggle_view', toggle_view_project_posts_path(:project_id => '1')

      post '/projects/1/posts/1/preview'
      assert_equal 'posts#preview', @response.body
      assert_equal '/projects/1/posts/1/preview', preview_project_post_path(:project_id => '1', :id => '1')

      get '/projects/1/posts/1/subscription'
      assert_equal 'subscriptions#show', @response.body
      assert_equal '/projects/1/posts/1/subscription', project_post_subscription_path(:project_id => '1', :post_id => '1')

      get '/projects/1/posts/1/comments'
      assert_equal 'comments#index', @response.body
      assert_equal '/projects/1/posts/1/comments', project_post_comments_path(:project_id => '1', :post_id => '1')

      post '/projects/1/posts/1/comments/preview'
      assert_equal 'comments#preview', @response.body
      assert_equal '/projects/1/posts/1/comments/preview', preview_project_post_comments_path(:project_id => '1', :post_id => '1')
    end
  end

  def test_replies
    with_test_routes do
      put '/replies/1/answer'
      assert_equal 'replies#mark_as_answer', @response.body

      delete '/replies/1/answer'
      assert_equal 'replies#unmark_as_answer', @response.body
    end
  end

  def test_resource_routes_with_only_and_except
    with_test_routes do
      get '/posts'
      assert_equal 'posts#index', @response.body
      assert_equal '/posts', posts_path

      get '/posts/1'
      assert_equal 'posts#show', @response.body
      assert_equal '/posts/1', post_path(:id => 1)

      get '/posts/1/comments'
      assert_equal 'comments#index', @response.body
      assert_equal '/posts/1/comments', post_comments_path(:post_id => 1)

      post '/posts'
      assert_equal 'pass', @response.headers['X-Cascade']
      put '/posts/1'
      assert_equal 'pass', @response.headers['X-Cascade']
      delete '/posts/1'
      assert_equal 'pass', @response.headers['X-Cascade']
      delete '/posts/1/comments'
      assert_equal 'pass', @response.headers['X-Cascade']
    end
  end

  def test_resource_routes_only_create_update_destroy
    with_test_routes do
      delete '/past'
      assert_equal 'pasts#destroy', @response.body
      assert_equal '/past', past_path

      put '/present'
      assert_equal 'presents#update', @response.body
      assert_equal '/present', present_path

      post '/future'
      assert_equal 'futures#create', @response.body
      assert_equal '/future', future_path
    end
  end

  def test_resources_routes_only_create_update_destroy
    with_test_routes do
      post '/relationships'
      assert_equal 'relationships#create', @response.body
      assert_equal '/relationships', relationships_path

      delete '/relationships/1'
      assert_equal 'relationships#destroy', @response.body
      assert_equal '/relationships/1', relationship_path(1)

      put '/friendships/1'
      assert_equal 'friendships#update', @response.body
      assert_equal '/friendships/1', friendship_path(1)
    end
  end

  def test_resource_with_slugs_in_ids
    with_test_routes do
      get '/posts/rails-rocks'
      assert_equal 'posts#show', @response.body
      assert_equal '/posts/rails-rocks', post_path(:id => 'rails-rocks')
    end
  end

  def test_resources_for_uncountable_names
    with_test_routes do
      assert_equal '/sheep', sheep_index_path
      assert_equal '/sheep/1', sheep_path(1)
      assert_equal '/sheep/new', new_sheep_path
      assert_equal '/sheep/1/edit', edit_sheep_path(1)
    end
  end

  def test_path_names
    with_test_routes do
      get '/pt/projetos'
      assert_equal 'projects#index', @response.body
      assert_equal '/pt/projetos', pt_projects_path

      get '/pt/projetos/1/editar'
      assert_equal 'projects#edit', @response.body
      assert_equal '/pt/projetos/1/editar', edit_pt_project_path(1)

      get '/pt/administrador'
      assert_equal 'admins#show', @response.body
      assert_equal '/pt/administrador', pt_admin_path

      get '/pt/administrador/novo'
      assert_equal 'admins#new', @response.body
      assert_equal '/pt/administrador/novo', new_pt_admin_path

      put '/pt/administrador/ativar'
      assert_equal 'admins#activate', @response.body
      assert_equal '/pt/administrador/ativar', activate_pt_admin_path
    end
  end

  def test_path_option_override
    with_test_routes do
      get '/pt/projetos/novo/abrir'
      assert_equal 'projects#open', @response.body
      assert_equal '/pt/projetos/novo/abrir', open_new_pt_project_path

      put '/pt/projetos/1/fechar'
      assert_equal 'projects#close', @response.body
      assert_equal '/pt/projetos/1/fechar', close_pt_project_path(1)
    end
  end

  def test_sprockets
    with_test_routes do
      get '/sprockets.js'
      assert_equal 'javascripts', @response.body
    end
  end

  def test_update_person_route
    with_test_routes do
      get '/people/1/update'
      assert_equal 'people#update', @response.body

      assert_equal '/people/1/update', update_person_path(:id => 1)
    end
  end

  def test_update_project_person
    with_test_routes do
      get '/projects/1/people/2/update'
      assert_equal 'people#update', @response.body

      assert_equal '/projects/1/people/2/update', update_project_person_path(:project_id => 1, :id => 2)
    end
  end

  def test_forum_products
    with_test_routes do
      get '/forum'
      assert_equal 'forum/products#index', @response.body
      assert_equal '/forum', forum_products_path

      get '/forum/basecamp'
      assert_equal 'forum/products#show', @response.body
      assert_equal '/forum/basecamp', forum_product_path(:id => 'basecamp')

      get '/forum/basecamp/questions'
      assert_equal 'forum/questions#index', @response.body
      assert_equal '/forum/basecamp/questions', forum_product_questions_path(:product_id => 'basecamp')

      get '/forum/basecamp/questions/1'
      assert_equal 'forum/questions#show', @response.body
      assert_equal '/forum/basecamp/questions/1', forum_product_question_path(:product_id => 'basecamp', :id => 1)
    end
  end

  def test_articles_perma
    with_test_routes do
      get '/articles/2009/08/18/rails-3'
      assert_equal 'articles#show', @response.body

      assert_equal '/articles/2009/8/18/rails-3', article_path(:year => 2009, :month => 8, :day => 18, :title => 'rails-3')
    end
  end

  def test_account_namespace
    with_test_routes do
      get '/account/subscription'
      assert_equal 'account/subscriptions#show', @response.body
      assert_equal '/account/subscription', account_subscription_path

      get '/account/credit'
      assert_equal 'account/credits#show', @response.body
      assert_equal '/account/credit', account_credit_path

      get '/account/credit_card'
      assert_equal 'account/credit_cards#show', @response.body
      assert_equal '/account/credit_card', account_credit_card_path
    end
  end

  def test_nested_namespace
    with_test_routes do
      get '/account/admin/subscription'
      assert_equal 'account/admin/subscriptions#show', @response.body
      assert_equal '/account/admin/subscription', account_admin_subscription_path
    end
  end

  def test_namespace_nested_in_resources
    with_test_routes do
      get '/clients/1/google/account'
      assert_equal '/clients/1/google/account', client_google_account_path(1)
      assert_equal 'google/accounts#show', @response.body

      get '/clients/1/google/account/secret/info'
      assert_equal '/clients/1/google/account/secret/info', client_google_account_secret_info_path(1)
      assert_equal 'google/secret/infos#show', @response.body
    end
  end

  def test_namespace_with_options
    with_test_routes do
      get '/usuarios'
      assert_equal '/usuarios', users_root_path
      assert_equal 'users/home#index', @response.body
    end
  end

  def test_articles_with_id
    with_test_routes do
      get '/articles/rails/1'
      assert_equal 'articles#with_id', @response.body

      get '/articles/123/1'
      assert_equal 'pass', @response.headers['X-Cascade']

      assert_equal '/articles/rails/1', article_with_title_path(:title => 'rails', :id => 1)
    end
  end

  def test_access_token_rooms
    with_test_routes do
      get '/12345/rooms'
      assert_equal 'rooms#index', @response.body

      get '/12345/rooms/1'
      assert_equal 'rooms#show', @response.body

      get '/12345/rooms/1/edit'
      assert_equal 'rooms#edit', @response.body
    end
  end

  def test_root
    with_test_routes do
      assert_equal '/', root_path
      get '/'
      assert_equal 'projects#index', @response.body
    end
  end

  def test_index
    with_test_routes do
      assert_equal '/info', info_path
      get '/info'
      assert_equal 'projects#info', @response.body
    end
  end

  def test_index
    with_test_routes do
      assert_equal '/info', info_path
      get '/info'
      assert_equal 'projects#info', @response.body
    end
  end

  def test_match_shorthand_with_no_scope
    with_test_routes do
      assert_equal '/account/overview', account_overview_path
      get '/account/overview'
      assert_equal 'account#overview', @response.body
    end
  end

  def test_match_shorthand_inside_namespace
    with_test_routes do
      assert_equal '/account/shorthand', account_shorthand_path
      get '/account/shorthand'
      assert_equal 'account#shorthand', @response.body
    end
  end

  def test_scoped_controller_with_namespace_and_action
    with_test_routes do
      assert_equal '/account/twitter/callback', account_callback_path("twitter")
      get '/account/twitter/callback'
      assert_equal 'account/callbacks#twitter', @response.body

      get '/account/whatever/callback'
      assert_equal 'Not Found', @response.body
    end
  end

  def test_convention_match_nested_and_with_leading_slash
    with_test_routes do
      assert_equal '/account/nested/overview', account_nested_overview_path
      get '/account/nested/overview'
      assert_equal 'account/nested#overview', @response.body
    end
  end

  def test_convention_with_explicit_end
    with_test_routes do
      get '/sign_in'
      assert_equal 'sessions#new', @response.body
      assert_equal '/sign_in', sign_in_path
    end
  end

  def test_redirect_with_complete_url
    with_test_routes do
      get '/account/google'
      assert_equal 301, @response.status
      assert_equal 'http://www.google.com/', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  end

  def test_redirect_with_port
    previous_host, self.host = self.host, 'www.example.com:3000'
    with_test_routes do
      get '/account/login'
      assert_equal 301, @response.status
      assert_equal 'http://www.example.com:3000/login', @response.headers['Location']
      assert_equal 'Moved Permanently', @response.body
    end
  ensure
    self.host = previous_host
  end

  def test_normalize_namespaced_matches
    with_test_routes do
      assert_equal '/account/description', account_description_path

      get '/account/description'
      assert_equal 'account#description', @response.body
    end
  end

  def test_namespaced_roots
    with_test_routes do
      assert_equal '/account', account_root_path
      get '/account'
      assert_equal 'account/account#index', @response.body
    end
  end

  def test_optional_scoped_root
    with_test_routes do
      assert_equal '/en', root_path("en")
      get '/en'
      assert_equal 'projects#index', @response.body
    end
  end

  def test_optional_scoped_path
    with_test_routes do
      assert_equal '/en/descriptions', descriptions_path("en")
      assert_equal '/descriptions', descriptions_path(nil)
      assert_equal '/en/descriptions/1', description_path("en", 1)
      assert_equal '/descriptions/1', description_path(nil, 1)

      get '/en/descriptions'
      assert_equal 'descriptions#index', @response.body

      get '/descriptions'
      assert_equal 'descriptions#index', @response.body

      get '/en/descriptions/1'
      assert_equal 'descriptions#show', @response.body

      get '/descriptions/1'
      assert_equal 'descriptions#show', @response.body
    end
  end

  def test_nested_optional_scoped_path
    with_test_routes do
      assert_equal '/admin/en/descriptions', admin_descriptions_path("en")
      assert_equal '/admin/descriptions', admin_descriptions_path(nil)
      assert_equal '/admin/en/descriptions/1', admin_description_path("en", 1)
      assert_equal '/admin/descriptions/1', admin_description_path(nil, 1)

      get '/admin/en/descriptions'
      assert_equal 'admin/descriptions#index', @response.body

      get '/admin/descriptions'
      assert_equal 'admin/descriptions#index', @response.body

      get '/admin/en/descriptions/1'
      assert_equal 'admin/descriptions#show', @response.body

      get '/admin/descriptions/1'
      assert_equal 'admin/descriptions#show', @response.body
    end
  end

  def test_default_params
    with_test_routes do
      get '/inline_pages'
      assert_equal 'home', @request.params[:id]

      get '/default_pages'
      assert_equal 'home', @request.params[:id]

      get '/scoped_pages'
      assert_equal 'home', @request.params[:id]
    end
  end

  def test_resource_constraints
    with_test_routes do
      get '/products/1'
      assert_equal 'pass', @response.headers['X-Cascade']
      get '/products'
      assert_equal 'products#root', @response.body
      get '/products/favorite'
      assert_equal 'products#favorite', @response.body
      get '/products/0001'
      assert_equal 'products#show', @response.body

      get '/products/1/images'
      assert_equal 'pass', @response.headers['X-Cascade']
      get '/products/0001/images'
      assert_equal 'images#index', @response.body
      get '/products/0001/images/0001'
      assert_equal 'images#show', @response.body

      get '/dashboard', {}, {'REMOTE_ADDR' => '10.0.0.100'}
      assert_equal 'pass', @response.headers['X-Cascade']
      get '/dashboard', {}, {'REMOTE_ADDR' => '192.168.1.100'}
      assert_equal 'dashboards#show', @response.body
    end
  end

  def test_root_works_in_the_resources_scope
    get '/products'
    assert_equal 'products#root', @response.body
    assert_equal '/products', products_root_path
  end

  def test_module_scope
    with_test_routes do
      get '/token'
      assert_equal 'api/tokens#show', @response.body
      assert_equal '/token', token_path
    end
  end

  def test_path_scope
    with_test_routes do
      get '/api/me'
      assert_equal 'mes#show', @response.body
      assert_equal '/api/me', me_path

      get '/api'
      assert_equal 'mes#index', @response.body
    end
  end

  def test_url_generator_for_generic_route
    with_test_routes do
      get 'whatever/foo/bar'
      assert_equal 'foo#bar', @response.body

      assert_equal 'http://www.example.com/whatever/foo/bar/1',
        url_for(:controller => "foo", :action => "bar", :id => 1)
    end
  end

  def test_url_generator_for_namespaced_generic_route
    with_test_routes do
      get 'whatever/foo/bar/show'
      assert_equal 'foo/bar#show', @response.body

      get 'whatever/foo/bar/show/1'
      assert_equal 'foo/bar#show', @response.body

      assert_equal 'http://www.example.com/whatever/foo/bar/show',
        url_for(:controller => "foo/bar", :action => "show")

      assert_equal 'http://www.example.com/whatever/foo/bar/show/1',
        url_for(:controller => "foo/bar", :action => "show", :id => '1')
    end
  end

  def test_assert_recognizes_account_overview
    with_test_routes do
      assert_recognizes({:controller => "account", :action => "overview"}, "/account/overview")
    end
  end

  def test_resource_new_actions
    with_test_routes do
      assert_equal '/replies/new/preview', preview_new_reply_path
      assert_equal '/pt/projetos/novo/preview', preview_new_pt_project_path
      assert_equal '/pt/administrador/novo/preview', preview_new_pt_admin_path
      assert_equal '/pt/products/novo/preview', preview_new_pt_product_path
      assert_equal '/profile/new/preview', preview_new_profile_path

      post '/replies/new/preview'
      assert_equal 'replies#preview', @response.body

      post '/pt/projetos/novo/preview'
      assert_equal 'projects#preview', @response.body

      post '/pt/administrador/novo/preview'
      assert_equal 'admins#preview', @response.body

      post '/pt/products/novo/preview'
      assert_equal 'products#preview', @response.body

      post '/profile/new/preview'
      assert_equal 'profiles#preview', @response.body
    end
  end

  def test_resource_merges_options_from_scope
    with_test_routes do
      assert_raise(NameError) { new_account_path }

      get '/account/new'
      assert_equal 404, status
    end
  end

  def test_resources_merges_options_from_scope
    with_test_routes do
      assert_raise(NoMethodError) { edit_product_path('1') }

      get '/products/1/edit'
      assert_equal 404, status

      assert_raise(NoMethodError) { edit_product_image_path('1', '2') }

      post '/products/1/images/2/edit'
      assert_equal 404, status
    end
  end

  def test_shallow_nested_resources
    with_test_routes do

      get '/api/teams'
      assert_equal 'api/teams#index', @response.body
      assert_equal '/api/teams', api_teams_path

      get '/api/teams/new'
      assert_equal 'api/teams#new', @response.body
      assert_equal '/api/teams/new', new_api_team_path

      get '/api/teams/1'
      assert_equal 'api/teams#show', @response.body
      assert_equal '/api/teams/1', api_team_path(:id => '1')

      get '/api/teams/1/edit'
      assert_equal 'api/teams#edit', @response.body
      assert_equal '/api/teams/1/edit', edit_api_team_path(:id => '1')

      get '/api/teams/1/players'
      assert_equal 'api/players#index', @response.body
      assert_equal '/api/teams/1/players', api_team_players_path(:team_id => '1')

      get '/api/teams/1/players/new'
      assert_equal 'api/players#new', @response.body
      assert_equal '/api/teams/1/players/new', new_api_team_player_path(:team_id => '1')

      get '/api/players/2'
      assert_equal 'api/players#show', @response.body
      assert_equal '/api/players/2', api_player_path(:id => '2')

      get '/api/players/2/edit'
      assert_equal 'api/players#edit', @response.body
      assert_equal '/api/players/2/edit', edit_api_player_path(:id => '2')

      get '/api/teams/1/captain'
      assert_equal 'api/captains#show', @response.body
      assert_equal '/api/teams/1/captain', api_team_captain_path(:team_id => '1')

      get '/api/teams/1/captain/new'
      assert_equal 'api/captains#new', @response.body
      assert_equal '/api/teams/1/captain/new', new_api_team_captain_path(:team_id => '1')

      get '/api/teams/1/captain/edit'
      assert_equal 'api/captains#edit', @response.body
      assert_equal '/api/teams/1/captain/edit', edit_api_team_captain_path(:team_id => '1')

      get '/threads'
      assert_equal 'threads#index', @response.body
      assert_equal '/threads', threads_path

      get '/threads/new'
      assert_equal 'threads#new', @response.body
      assert_equal '/threads/new', new_thread_path

      get '/threads/1'
      assert_equal 'threads#show', @response.body
      assert_equal '/threads/1', thread_path(:id => '1')

      get '/threads/1/edit'
      assert_equal 'threads#edit', @response.body
      assert_equal '/threads/1/edit', edit_thread_path(:id => '1')

      get '/threads/1/owner'
      assert_equal 'owners#show', @response.body
      assert_equal '/threads/1/owner', thread_owner_path(:thread_id => '1')

      get '/threads/1/messages'
      assert_equal 'messages#index', @response.body
      assert_equal '/threads/1/messages', thread_messages_path(:thread_id => '1')

      get '/threads/1/messages/new'
      assert_equal 'messages#new', @response.body
      assert_equal '/threads/1/messages/new', new_thread_message_path(:thread_id => '1')

      get '/messages/2'
      assert_equal 'messages#show', @response.body
      assert_equal '/messages/2', message_path(:id => '2')

      get '/messages/2/edit'
      assert_equal 'messages#edit', @response.body
      assert_equal '/messages/2/edit', edit_message_path(:id => '2')

      get '/messages/2/comments'
      assert_equal 'comments#index', @response.body
      assert_equal '/messages/2/comments', message_comments_path(:message_id => '2')

      get '/messages/2/comments/new'
      assert_equal 'comments#new', @response.body
      assert_equal '/messages/2/comments/new', new_message_comment_path(:message_id => '2')

      get '/comments/3'
      assert_equal 'comments#show', @response.body
      assert_equal '/comments/3', comment_path(:id => '3')

      get '/comments/3/edit'
      assert_equal 'comments#edit', @response.body
      assert_equal '/comments/3/edit', edit_comment_path(:id => '3')

      post '/comments/3/preview'
      assert_equal 'comments#preview', @response.body
      assert_equal '/comments/3/preview', preview_comment_path(:id => '3')
    end
  end

  def test_custom_resource_routes_are_scoped
    with_test_routes do
      assert_equal '/customers/recent', recent_customers_path
      assert_equal '/customers/1/profile', profile_customer_path(:id => '1')
      assert_equal '/customers/new/preview', preview_new_customer_path
      assert_equal '/customers/1/avatar/thumbnail.jpg', thumbnail_customer_avatar_path(:customer_id => '1', :format => :jpg)
      assert_equal '/customers/1/invoices/outstanding', outstanding_customer_invoices_path(:customer_id => '1')
      assert_equal '/customers/1/invoices/2/print', print_customer_invoice_path(:customer_id => '1', :id => '2')
      assert_equal '/customers/1/invoices/new/preview', preview_new_customer_invoice_path(:customer_id => '1')
      assert_equal '/customers/1/notes/new/preview', preview_new_customer_note_path(:customer_id => '1')
      assert_equal '/notes/1/print', print_note_path(:id => '1')
      assert_equal '/api/customers/recent', recent_api_customers_path
      assert_equal '/api/customers/1/profile', profile_api_customer_path(:id => '1')
      assert_equal '/api/customers/new/preview', preview_new_api_customer_path

      get '/customers/1/invoices/overdue'
      assert_equal 'invoices#overdue', @response.body
    end
  end

  def test_shallow_nested_routes_ignore_module
    with_test_routes do
      get '/errors/1/notices'
      assert_equal 'api/notices#index', @response.body
      assert_equal '/errors/1/notices', error_notices_path(:error_id => '1')

      get '/notices/1'
      assert_equal 'api/notices#show', @response.body
      assert_equal '/notices/1', notice_path(:id => '1')
    end
  end

  def test_non_greedy_regexp
    with_test_routes do
      get '/api/1.0/users'
      assert_equal 'api/users#index', @response.body
      assert_equal '/api/1.0/users', api_users_path(:version => '1.0')

      get '/api/1.0/users.json'
      assert_equal 'api/users#index', @response.body
      assert_equal true, @request.format.json?
      assert_equal '/api/1.0/users.json', api_users_path(:version => '1.0', :format => :json)

      get '/api/1.0/users/first.last'
      assert_equal 'api/users#show', @response.body
      assert_equal 'first.last', @request.params[:id]
      assert_equal '/api/1.0/users/first.last', api_user_path(:version => '1.0', :id => 'first.last')

      get '/api/1.0/users/first.last.xml'
      assert_equal 'api/users#show', @response.body
      assert_equal 'first.last', @request.params[:id]
      assert_equal true, @request.format.xml?
      assert_equal '/api/1.0/users/first.last.xml', api_user_path(:version => '1.0', :id => 'first.last', :format => :xml)
    end
  end

  def test_glob_parameter_accepts_regexp
    with_test_routes do
      get '/en/path/to/existing/file.html'
      assert_equal 200, @response.status
    end
  end

  def test_resources_controller_name_is_not_pluralized
    with_test_routes do
      get '/content'
      assert_equal 'content#index', @response.body
    end
  end

  def test_url_generator_for_optional_prefix_dynamic_segment
    with_test_routes do
      get '/bob/followers'
      assert_equal 'followers#index', @response.body
      assert_equal 'http://www.example.com/bob/followers',
        url_for(:controller => "followers", :action => "index", :username => "bob")

      get '/followers'
      assert_equal 'followers#index', @response.body
      assert_equal 'http://www.example.com/followers',
        url_for(:controller => "followers", :action => "index", :username => nil)
    end
  end

  def test_url_generator_for_optional_suffix_static_and_dynamic_segment
    with_test_routes do
      get '/groups/user/bob'
      assert_equal 'groups#index', @response.body
      assert_equal 'http://www.example.com/groups/user/bob',
        url_for(:controller => "groups", :action => "index", :username => "bob")

      get '/groups'
      assert_equal 'groups#index', @response.body
      assert_equal 'http://www.example.com/groups',
        url_for(:controller => "groups", :action => "index", :username => nil)
    end
  end

  def test_url_generator_for_optional_prefix_static_and_dynamic_segment
    with_test_routes do
      get 'user/bob/photos'
      assert_equal 'photos#index', @response.body
      assert_equal 'http://www.example.com/user/bob/photos',
        url_for(:controller => "photos", :action => "index", :username => "bob")

      get 'photos'
      assert_equal 'photos#index', @response.body
      assert_equal 'http://www.example.com/photos',
        url_for(:controller => "photos", :action => "index", :username => nil)
    end
  end

  def test_url_recognition_for_optional_static_segments
    with_test_routes do
      get '/groups/discussions/messages'
      assert_equal 'messages#index', @response.body

      get '/groups/discussions/messages/1'
      assert_equal 'messages#show', @response.body

      get '/groups/messages'
      assert_equal 'messages#index', @response.body

      get '/groups/messages/1'
      assert_equal 'messages#show', @response.body

      get '/discussions/messages'
      assert_equal 'messages#index', @response.body

      get '/discussions/messages/1'
      assert_equal 'messages#show', @response.body

      get '/messages'
      assert_equal 'messages#index', @response.body

      get '/messages/1'
      assert_equal 'messages#show', @response.body
    end
  end

  def test_router_removes_invalid_conditions
    with_test_routes do
      get '/tickets'
      assert_equal 'tickets#index', @response.body
      assert_equal '/tickets', tickets_path
    end
  end

  def test_constraints_are_merged_from_scope
    with_test_routes do
      get '/movies/0001'
      assert_equal 'movies#show', @response.body
      assert_equal '/movies/0001', movie_path(:id => '0001')

      get '/movies/00001'
      assert_equal 'Not Found', @response.body
      assert_raises(ActionController::RoutingError){ movie_path(:id => '00001') }

      get '/movies/0001/reviews'
      assert_equal 'reviews#index', @response.body
      assert_equal '/movies/0001/reviews', movie_reviews_path(:movie_id => '0001')

      get '/movies/00001/reviews'
      assert_equal 'Not Found', @response.body
      assert_raises(ActionController::RoutingError){ movie_reviews_path(:movie_id => '00001') }

      get '/movies/0001/reviews/0001'
      assert_equal 'reviews#show', @response.body
      assert_equal '/movies/0001/reviews/0001', movie_review_path(:movie_id => '0001', :id => '0001')

      get '/movies/00001/reviews/0001'
      assert_equal 'Not Found', @response.body
      assert_raises(ActionController::RoutingError){ movie_path(:movie_id => '00001', :id => '00001') }

      get '/movies/0001/trailer'
      assert_equal 'trailers#show', @response.body
      assert_equal '/movies/0001/trailer', movie_trailer_path(:movie_id => '0001')

      get '/movies/00001/trailer'
      assert_equal 'Not Found', @response.body
      assert_raises(ActionController::RoutingError){ movie_trailer_path(:movie_id => '00001') }
    end
  end

  def test_only_should_be_read_from_scope
    with_test_routes do
      get '/only/clubs'
      assert_equal 'only/clubs#index', @response.body
      assert_equal '/only/clubs', only_clubs_path

      get '/only/clubs/1/edit'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { edit_only_club_path(:id => '1') }

      get '/only/clubs/1/players'
      assert_equal 'only/players#index', @response.body
      assert_equal '/only/clubs/1/players', only_club_players_path(:club_id => '1')

      get '/only/clubs/1/players/2/edit'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { edit_only_club_player_path(:club_id => '1', :id => '2') }

      get '/only/clubs/1/chairman'
      assert_equal 'only/chairmen#show', @response.body
      assert_equal '/only/clubs/1/chairman', only_club_chairman_path(:club_id => '1')

      get '/only/clubs/1/chairman/edit'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { edit_only_club_chairman_path(:club_id => '1') }
    end
  end

  def test_except_should_be_read_from_scope
    with_test_routes do
      get '/except/clubs'
      assert_equal 'except/clubs#index', @response.body
      assert_equal '/except/clubs', except_clubs_path

      get '/except/clubs/1/edit'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { edit_except_club_path(:id => '1') }

      get '/except/clubs/1/players'
      assert_equal 'except/players#index', @response.body
      assert_equal '/except/clubs/1/players', except_club_players_path(:club_id => '1')

      get '/except/clubs/1/players/2/edit'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { edit_except_club_player_path(:club_id => '1', :id => '2') }

      get '/except/clubs/1/chairman'
      assert_equal 'except/chairmen#show', @response.body
      assert_equal '/except/clubs/1/chairman', except_club_chairman_path(:club_id => '1')

      get '/except/clubs/1/chairman/edit'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { edit_except_club_chairman_path(:club_id => '1') }
    end
  end

  def test_only_option_should_override_scope
    with_test_routes do
      get '/only/sectors'
      assert_equal 'only/sectors#index', @response.body
      assert_equal '/only/sectors', only_sectors_path

      get '/only/sectors/1'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { only_sector_path(:id => '1') }
    end
  end

  def test_only_option_should_not_inherit
    with_test_routes do
      get '/only/sectors/1/companies/2'
      assert_equal 'only/companies#show', @response.body
      assert_equal '/only/sectors/1/companies/2', only_sector_company_path(:sector_id => '1', :id => '2')

      get '/only/sectors/1/leader'
      assert_equal 'only/leaders#show', @response.body
      assert_equal '/only/sectors/1/leader', only_sector_leader_path(:sector_id => '1')
    end
  end

  def test_except_option_should_override_scope
    with_test_routes do
      get '/except/sectors'
      assert_equal 'except/sectors#index', @response.body
      assert_equal '/except/sectors', except_sectors_path

      get '/except/sectors/1'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { except_sector_path(:id => '1') }
    end
  end

  def test_except_option_should_not_inherit
    with_test_routes do
      get '/except/sectors/1/companies/2'
      assert_equal 'except/companies#show', @response.body
      assert_equal '/except/sectors/1/companies/2', except_sector_company_path(:sector_id => '1', :id => '2')

      get '/except/sectors/1/leader'
      assert_equal 'except/leaders#show', @response.body
      assert_equal '/except/sectors/1/leader', except_sector_leader_path(:sector_id => '1')
    end
  end

  def test_except_option_should_override_scoped_only
    with_test_routes do
      get '/only/sectors/1/managers'
      assert_equal 'only/managers#index', @response.body
      assert_equal '/only/sectors/1/managers', only_sector_managers_path(:sector_id => '1')

      get '/only/sectors/1/managers/2'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { only_sector_manager_path(:sector_id => '1', :id => '2') }
    end
  end

  def test_only_option_should_override_scoped_except
    with_test_routes do
      get '/except/sectors/1/managers'
      assert_equal 'except/managers#index', @response.body
      assert_equal '/except/sectors/1/managers', except_sector_managers_path(:sector_id => '1')

      get '/except/sectors/1/managers/2'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { except_sector_manager_path(:sector_id => '1', :id => '2') }
    end
  end

  def test_only_scope_should_override_parent_scope
    with_test_routes do
      get '/only/sectors/1/companies/2/divisions'
      assert_equal 'only/divisions#index', @response.body
      assert_equal '/only/sectors/1/companies/2/divisions', only_sector_company_divisions_path(:sector_id => '1', :company_id => '2')

      get '/only/sectors/1/companies/2/divisions/3'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { only_sector_company_division_path(:sector_id => '1', :company_id => '2', :id => '3') }
    end
  end

  def test_except_scope_should_override_parent_scope
    with_test_routes do
      get '/except/sectors/1/companies/2/divisions'
      assert_equal 'except/divisions#index', @response.body
      assert_equal '/except/sectors/1/companies/2/divisions', except_sector_company_divisions_path(:sector_id => '1', :company_id => '2')

      get '/except/sectors/1/companies/2/divisions/3'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { except_sector_company_division_path(:sector_id => '1', :company_id => '2', :id => '3') }
    end
  end

  def test_except_scope_should_override_parent_only_scope
    with_test_routes do
      get '/only/sectors/1/companies/2/departments'
      assert_equal 'only/departments#index', @response.body
      assert_equal '/only/sectors/1/companies/2/departments', only_sector_company_departments_path(:sector_id => '1', :company_id => '2')

      get '/only/sectors/1/companies/2/departments/3'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { only_sector_company_department_path(:sector_id => '1', :company_id => '2', :id => '3') }
    end
  end

  def test_only_scope_should_override_parent_except_scope
    with_test_routes do
      get '/except/sectors/1/companies/2/departments'
      assert_equal 'except/departments#index', @response.body
      assert_equal '/except/sectors/1/companies/2/departments', except_sector_company_departments_path(:sector_id => '1', :company_id => '2')

      get '/except/sectors/1/companies/2/departments/3'
      assert_equal 'Not Found', @response.body
      assert_raise(NoMethodError) { except_sector_company_department_path(:sector_id => '1', :company_id => '2', :id => '3') }
    end
  end

  private
    def with_test_routes
      yield
    end
end
