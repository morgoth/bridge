require 'abstract_unit'
require 'controller/fake_controllers'
require 'action_controller/vendor/html-scanner'

class SessionTest < Test::Unit::TestCase
  StubApp = lambda { |env|
    [200, {"Content-Type" => "text/html", "Content-Length" => "13"}, ["Hello, World!"]]
  }

  def setup
    @session = ActionController::Integration::Session.new(StubApp)
  end

  def test_https_bang_works_and_sets_truth_by_default
    assert !@session.https?
    @session.https!
    assert @session.https?
    @session.https! false
    assert !@session.https?
  end

  def test_host!
    assert_not_equal "glu.ttono.us", @session.host
    @session.host! "rubyonrails.com"
    assert_equal "rubyonrails.com", @session.host
  end

  def test_follow_redirect_raises_when_no_redirect
    @session.stubs(:redirect?).returns(false)
    assert_raise(RuntimeError) { @session.follow_redirect! }
  end

  def test_request_via_redirect_uses_given_method
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue"}
    @session.expects(:process).with(:put, path, args, headers)
    @session.stubs(:redirect?).returns(false)
    @session.request_via_redirect(:put, path, args, headers)
  end

  def test_request_via_redirect_follows_redirects
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue"}
    @session.stubs(:redirect?).returns(true, true, false)
    @session.expects(:follow_redirect!).times(2)
    @session.request_via_redirect(:get, path, args, headers)
  end

  def test_request_via_redirect_returns_status
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue"}
    @session.stubs(:redirect?).returns(false)
    @session.stubs(:status).returns(200)
    assert_equal 200, @session.request_via_redirect(:get, path, args, headers)
  end

  def test_get_via_redirect
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue" }
    @session.expects(:request_via_redirect).with(:get, path, args, headers)
    @session.get_via_redirect(path, args, headers)
  end

  def test_post_via_redirect
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue" }
    @session.expects(:request_via_redirect).with(:post, path, args, headers)
    @session.post_via_redirect(path, args, headers)
  end

  def test_put_via_redirect
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue" }
    @session.expects(:request_via_redirect).with(:put, path, args, headers)
    @session.put_via_redirect(path, args, headers)
  end

  def test_delete_via_redirect
    path = "/somepath"; args = {:id => '1'}; headers = {"X-Test-Header" => "testvalue" }
    @session.expects(:request_via_redirect).with(:delete, path, args, headers)
    @session.delete_via_redirect(path, args, headers)
  end

  def test_get
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    @session.expects(:process).with(:get,path,params,headers)
    @session.get(path,params,headers)
  end

  def test_post
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    @session.expects(:process).with(:post,path,params,headers)
    @session.post(path,params,headers)
  end

  def test_put
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    @session.expects(:process).with(:put,path,params,headers)
    @session.put(path,params,headers)
  end

  def test_delete
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    @session.expects(:process).with(:delete,path,params,headers)
    @session.delete(path,params,headers)
  end

  def test_head
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    @session.expects(:process).with(:head,path,params,headers)
    @session.head(path,params,headers)
  end

  def test_xml_http_request_get
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    headers_after_xhr = headers.merge(
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest",
      "HTTP_ACCEPT"           => "text/javascript, text/html, application/xml, text/xml, */*"
    )
    @session.expects(:process).with(:get,path,params,headers_after_xhr)
    @session.xml_http_request(:get,path,params,headers)
  end

  def test_xml_http_request_post
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    headers_after_xhr = headers.merge(
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest",
      "HTTP_ACCEPT"           => "text/javascript, text/html, application/xml, text/xml, */*"
    )
    @session.expects(:process).with(:post,path,params,headers_after_xhr)
    @session.xml_http_request(:post,path,params,headers)
  end

  def test_xml_http_request_put
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    headers_after_xhr = headers.merge(
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest",
      "HTTP_ACCEPT"           => "text/javascript, text/html, application/xml, text/xml, */*"
    )
    @session.expects(:process).with(:put,path,params,headers_after_xhr)
    @session.xml_http_request(:put,path,params,headers)
  end

  def test_xml_http_request_delete
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    headers_after_xhr = headers.merge(
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest",
      "HTTP_ACCEPT"           => "text/javascript, text/html, application/xml, text/xml, */*"
    )
    @session.expects(:process).with(:delete,path,params,headers_after_xhr)
    @session.xml_http_request(:delete,path,params,headers)
  end

  def test_xml_http_request_head
    path = "/index"; params = "blah"; headers = {:location => 'blah'}
    headers_after_xhr = headers.merge(
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest",
      "HTTP_ACCEPT"           => "text/javascript, text/html, application/xml, text/xml, */*"
    )
    @session.expects(:process).with(:head,path,params,headers_after_xhr)
    @session.xml_http_request(:head,path,params,headers)
  end

  def test_xml_http_request_override_accept
    path = "/index"; params = "blah"; headers = {:location => 'blah', "HTTP_ACCEPT" => "application/xml"}
    headers_after_xhr = headers.merge(
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"
    )
    @session.expects(:process).with(:post,path,params,headers_after_xhr)
    @session.xml_http_request(:post,path,params,headers)
  end
end

class IntegrationTestTest < Test::Unit::TestCase
  def setup
    @test = ::ActionController::IntegrationTest.new(:default_test)
    @test.class.stubs(:fixture_table_names).returns([])
    @session = @test.open_session
  end

  def test_opens_new_session
    session1 = @test.open_session { |sess| }
    session2 = @test.open_session # implicit session

    assert_respond_to session1, :assert_template, "open_session makes assert_template available"
    assert_respond_to session2, :assert_template, "open_session makes assert_template available"
    assert !session1.equal?(session2)
  end

  # RSpec mixes Matchers (which has a #method_missing) into
  # IntegrationTest's superclass.  Make sure IntegrationTest does not
  # try to delegate these methods to the session object.
  def test_does_not_prevent_method_missing_passing_up_to_ancestors
    mixin = Module.new do
      def method_missing(name, *args)
        name.to_s == 'foo' ? 'pass' : super
      end
    end
    @test.class.superclass.__send__(:include, mixin)
    begin
      assert_equal 'pass', @test.foo
    ensure
      # leave other tests as unaffected as possible
      mixin.__send__(:remove_method, :method_missing)
    end
  end
end

# Tests that integration tests don't call Controller test methods for processing.
# Integration tests have their own setup and teardown.
class IntegrationTestUsesCorrectClass < ActionController::IntegrationTest
  def self.fixture_table_names
    []
  end

  def test_integration_methods_called
    reset!
    @integration_session.stubs(:generic_url_rewriter)
    @integration_session.stubs(:process)

    %w( get post head put delete ).each do |verb|
      assert_nothing_raised("'#{verb}' should use integration test methods") { __send__(verb, '/') }
    end
  end
end

class IntegrationProcessTest < ActionController::IntegrationTest
  class IntegrationController < ActionController::Base
    def get
      respond_to do |format|
        format.html { render :text => "OK", :status => 200 }
        format.js { render :text => "JS OK", :status => 200 }
      end
    end

    def get_with_params
      render :text => "foo: #{params[:foo]}", :status => 200
    end

    def post
      render :text => "Created", :status => 201
    end

    def method
      render :text => "method: #{request.method.downcase}"
    end

    def cookie_monster
      cookies["cookie_1"] = nil
      cookies["cookie_3"] = "chocolate"
      render :text => "Gone", :status => 410
    end

    def set_cookie
      cookies["foo"] = 'bar'
      head :ok
    end

    def get_cookie
      render :text => cookies["foo"]
    end

    def redirect
      redirect_to :action => "get"
    end
  end

  def test_get
    with_test_route_set do
      get '/get'
      assert_equal 200, status
      assert_equal "OK", status_message
      assert_response 200
      assert_response :success
      assert_response :ok
      assert_equal({}, cookies.to_hash)
      assert_equal "OK", body
      assert_equal "OK", response.body
      assert_kind_of HTML::Document, html_document
      assert_equal 1, request_count
    end
  end

  def test_post
    with_test_route_set do
      post '/post'
      assert_equal 201, status
      assert_equal "Created", status_message
      assert_response 201
      assert_response :success
      assert_response :created
      assert_equal({}, cookies.to_hash)
      assert_equal "Created", body
      assert_equal "Created", response.body
      assert_kind_of HTML::Document, html_document
      assert_equal 1, request_count
    end
  end

  test 'response cookies are added to the cookie jar for the next request' do
    with_test_route_set do
      self.cookies['cookie_1'] = "sugar"
      self.cookies['cookie_2'] = "oatmeal"
      get '/cookie_monster'
      assert_equal "cookie_1=; path=/\ncookie_3=chocolate; path=/", headers["Set-Cookie"]
      assert_equal({"cookie_1"=>"", "cookie_2"=>"oatmeal", "cookie_3"=>"chocolate"}, cookies.to_hash)
    end
  end

  test 'cookie persist to next request' do
    with_test_route_set do
      get '/set_cookie'
      assert_response :success

      assert_equal "foo=bar; path=/", headers["Set-Cookie"]
      assert_equal({"foo"=>"bar"}, cookies.to_hash)

      get '/get_cookie'
      assert_response :success
      assert_equal "bar", body

      assert_equal nil, headers["Set-Cookie"]
      assert_equal({"foo"=>"bar"}, cookies.to_hash)
    end
  end

  test 'cookie persist to next request on another domain' do
    with_test_route_set do
      host! "37s.backpack.test"

      get '/set_cookie'
      assert_response :success

      assert_equal "foo=bar; path=/", headers["Set-Cookie"]
      assert_equal({"foo"=>"bar"}, cookies.to_hash)

      get '/get_cookie'
      assert_response :success
      assert_equal "bar", body

      assert_equal nil, headers["Set-Cookie"]
      assert_equal({"foo"=>"bar"}, cookies.to_hash)
    end
  end

  def test_redirect
    with_test_route_set do
      get '/redirect'
      assert_equal 302, status
      assert_equal "Found", status_message
      assert_response 302
      assert_response :redirect
      assert_response :found
      assert_equal "<html><body>You are being <a href=\"http://www.example.com/get\">redirected</a>.</body></html>", response.body
      assert_kind_of HTML::Document, html_document
      assert_equal 1, request_count

      follow_redirect!
      assert_response :success
      assert_equal "/get", path
    end
  end

  def test_xml_http_request_get
    with_test_route_set do
      xhr :get, '/get'
      assert_equal 200, status
      assert_equal "OK", status_message
      assert_response 200
      assert_response :success
      assert_response :ok
      assert_equal "JS OK", response.body
    end
  end

  def test_get_with_query_string
    with_test_route_set do
      get '/get_with_params?foo=bar'
      assert_equal '/get_with_params?foo=bar', request.env["REQUEST_URI"]
      assert_equal '/get_with_params?foo=bar', request.fullpath
      assert_equal "foo=bar", request.env["QUERY_STRING"]
      assert_equal 'foo=bar', request.query_string
      assert_equal 'bar', request.parameters['foo']

      assert_equal 200, status
      assert_equal "foo: bar", response.body
    end
  end

  def test_get_with_parameters
    with_test_route_set do
      get '/get_with_params', :foo => "bar"
      assert_equal '/get_with_params', request.env["PATH_INFO"]
      assert_equal '/get_with_params', request.path_info
      assert_equal 'foo=bar', request.env["QUERY_STRING"]
      assert_equal 'foo=bar', request.query_string
      assert_equal 'bar', request.parameters['foo']

      assert_equal 200, status
      assert_equal "foo: bar", response.body
    end
  end

  def test_head
    with_test_route_set do
      head '/get'
      assert_equal 200, status
      assert_equal "", body

      head '/post'
      assert_equal 201, status
      assert_equal "", body

      get '/get/method'
      assert_equal 200, status
      assert_equal "method: get", body

      head '/get/method'
      assert_equal 200, status
      assert_equal "", body
    end
  end

  def test_generate_url_with_controller
    assert_equal 'http://www.example.com/foo', url_for(:controller => "foo")
  end

  private
    def with_test_route_set
      with_routing do |set|
        controller = ::IntegrationProcessTest::IntegrationController.clone
        controller.class_eval do
          include set.url_helpers
        end

        set.draw do |map|
          match ':action', :to => controller
          get 'get/:action', :to => controller
        end

        self.singleton_class.send(:include, set.url_helpers)

        yield
      end
    end
end

class MetalIntegrationTest < ActionController::IntegrationTest
  include SharedTestRoutes.url_helpers

  class Poller
    def self.call(env)
      if env["PATH_INFO"] =~ /^\/success/
        [200, {"Content-Type" => "text/plain", "Content-Length" => "12"}, ["Hello World!"]]
      else
        [404, {"Content-Type" => "text/plain", "Content-Length" => "0"}, []]
      end
    end
  end

  def setup
    @app = Poller
  end

  def test_successful_get
    get "/success"
    assert_response 200
    assert_response :success
    assert_response :ok
    assert_equal "Hello World!", response.body
  end

  def test_failed_get
    get "/failure"
    assert_response 404
    assert_response :not_found
    assert_equal '', response.body
  end

  def test_generate_url_without_controller
    assert_equal 'http://www.example.com/foo', url_for(:controller => "foo")
  end
end

class ApplicationIntegrationTest < ActionController::IntegrationTest
  class TestController < ActionController::Base
    def index
      render :text => "index"
    end
  end

  def self.call(env)
    routes.call(env)
  end

  def self.routes
    @routes ||= ActionDispatch::Routing::RouteSet.new
  end

  routes.draw do
    match 'foo', :to => 'application_integration_test/test#index', :as => :foo
    match 'bar', :to => 'application_integration_test/test#index', :as => :bar
  end

  def app
    self.class
  end

  test "includes route helpers" do
    assert_equal '/foo', foo_path
    assert_equal '/bar', bar_path
  end

  test "route helpers after controller access" do
    get '/foo'
    assert_equal '/foo', foo_path

    get '/bar'
    assert_equal '/bar', bar_path
  end

  test "missing route helper before controller access" do
    assert_raise(NameError) { missing_path }
  end

  test "missing route helper after controller access" do
    get '/foo'
    assert_raise(NameError) { missing_path }
  end
end
