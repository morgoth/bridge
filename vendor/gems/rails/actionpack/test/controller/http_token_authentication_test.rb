require 'abstract_unit'

class HttpTokenAuthenticationTest < ActionController::TestCase
  class DummyController < ActionController::Base
    before_filter :authenticate, :only => :index
    before_filter :authenticate_with_request, :only => :display
    before_filter :authenticate_long_credentials, :only => :show

    def index
      render :text => "Hello Secret"
    end

    def display
      render :text => 'Definitely Maybe'
    end
    
    def show
      render :text => 'Only for loooooong credentials'
    end

    private

    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        token == 'lifo'
      end
    end

    def authenticate_with_request
      if authenticate_with_http_token { |token, options| token == '"quote" pretty' && options[:algorithm] == 'test' }
        @logged_in = true
      else
        request_http_token_authentication("SuperSecret")
      end
    end
    
    def authenticate_long_credentials
      authenticate_or_request_with_http_token do |token, options|
        token == '1234567890123456789012345678901234567890' && options[:algorithm] == 'test'
      end
    end
  end

  AUTH_HEADERS = ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION', 'X_HTTP_AUTHORIZATION', 'REDIRECT_X_HTTP_AUTHORIZATION']

  tests DummyController

  AUTH_HEADERS.each do |header|
    test "successful authentication with #{header.downcase}" do
      @request.env[header] = encode_credentials('lifo')
      get :index

      assert_response :success
      assert_equal 'Hello Secret', @response.body, "Authentication failed for request header #{header}"
    end
    test "successful authentication with #{header.downcase} and long credentials" do
      @request.env[header] = encode_credentials('1234567890123456789012345678901234567890', :algorithm => 'test')
      get :show
      
      assert_response :success
      assert_equal 'Only for loooooong credentials', @response.body, "Authentication failed for request header #{header} and long credentials"
    end
  end

  AUTH_HEADERS.each do |header|
    test "unsuccessful authentication with #{header.downcase}" do
      @request.env[header] = encode_credentials('h4x0r')
      get :index

      assert_response :unauthorized
      assert_equal "HTTP Token: Access denied.\n", @response.body, "Authentication didn't fail for request header #{header}"
    end
    test "unsuccessful authentication with #{header.downcase} and long credentials" do
      @request.env[header] = encode_credentials('h4x0rh4x0rh4x0rh4x0rh4x0rh4x0rh4x0rh4x0r')
      get :show

      assert_response :unauthorized
      assert_equal "HTTP Token: Access denied.\n", @response.body, "Authentication didn't fail for request header #{header} and long credentials"
    end
  end

  test "authentication request without credential" do
    get :display

    assert_response :unauthorized
    assert_equal "HTTP Token: Access denied.\n", @response.body
    assert_equal 'Token realm="SuperSecret"', @response.headers['WWW-Authenticate']
  end

  test "authentication request with invalid credential" do
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials('"quote" pretty')
    get :display

    assert_response :unauthorized
    assert_equal "HTTP Token: Access denied.\n", @response.body
    assert_equal 'Token realm="SuperSecret"', @response.headers['WWW-Authenticate']
  end

  test "authentication request with valid credential" do
    @request.env['HTTP_AUTHORIZATION'] = encode_credentials('"quote" pretty', :algorithm => 'test')
    get :display

    assert_response :success
    assert assigns(:logged_in)
    assert_equal 'Definitely Maybe', @response.body
  end

  private

  def encode_credentials(token, options = {})
    ActionController::HttpAuthentication::Token.encode_credentials(token, options)
  end
end
