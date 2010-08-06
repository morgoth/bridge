require 'abstract_unit'

class CookiesTest < ActionController::TestCase
  class TestController < ActionController::Base
    def authenticate
      cookies["user_name"] = "david"
      head :ok
    end

    def set_with_with_escapable_characters
      cookies["that & guy"] = "foo & bar => baz"
      head :ok
    end

    def authenticate_for_fourteen_days
      cookies["user_name"] = { "value" => "david", "expires" => Time.utc(2005, 10, 10,5) }
      head :ok
    end

    def authenticate_for_fourteen_days_with_symbols
      cookies[:user_name] = { :value => "david", :expires => Time.utc(2005, 10, 10,5) }
      head :ok
    end

    def set_multiple_cookies
      cookies["user_name"] = { "value" => "david", "expires" => Time.utc(2005, 10, 10,5) }
      cookies["login"]     = "XJ-122"
      head :ok
    end

    def access_frozen_cookies
      cookies["will"] = "work"
      head :ok
    end

    def logout
      cookies.delete("user_name")
      head :ok
    end

    def delete_cookie_with_path
      cookies.delete("user_name", :path => '/beaten')
      head :ok
    end

    def authenticate_with_http_only
      cookies["user_name"] = { :value => "david", :httponly => true }
      head :ok
    end

    def set_permanent_cookie
      cookies.permanent[:user_name] = "Jamie"
      head :ok
    end

    def set_signed_cookie
      cookies.signed[:user_id] = 45
      head :ok
    end

    def raise_data_overflow
      cookies.signed[:foo] = 'bye!' * 1024
      head :ok
    end

    def tampered_cookies
      cookies[:tampered] = "BAh7BjoIZm9vIghiYXI%3D--123456780"
      cookies.signed[:tampered]
      head :ok
    end

    def set_permanent_signed_cookie
      cookies.permanent.signed[:remember_me] = 100
      head :ok
    end

    def delete_and_set_cookie
      cookies.delete :user_name
      cookies[:user_name] = { :value => "david", :expires => Time.utc(2005, 10, 10,5) }
      head :ok
    end

    def set_cookie_with_domain
      cookies[:user_name] = {:value => "rizwanreza", :domain => :all}
      head :ok
    end

    def delete_cookie_with_domain
      cookies.delete(:user_name, :domain => :all)
      head :ok
    end
  end

  tests TestController

  def setup
    super
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.host = "www.nextangle.com"
  end

  def test_setting_cookie
    get :authenticate
    assert_cookie_header "user_name=david; path=/"
    assert_equal({"user_name" => "david"}, @response.cookies)
  end

  def test_setting_with_escapable_characters
    get :set_with_with_escapable_characters
    assert_cookie_header "that+%26+guy=foo+%26+bar+%3D%3E+baz; path=/"
    assert_equal({"that & guy" => "foo & bar => baz"}, @response.cookies)
  end

  def test_setting_cookie_for_fourteen_days
    get :authenticate_for_fourteen_days
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10-Oct-2005 05:00:00 GMT"
    assert_equal({"user_name" => "david"}, @response.cookies)
  end

  def test_setting_cookie_for_fourteen_days_with_symbols
    get :authenticate_for_fourteen_days_with_symbols
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10-Oct-2005 05:00:00 GMT"
    assert_equal({"user_name" => "david"}, @response.cookies)
  end

  def test_setting_cookie_with_http_only
    get :authenticate_with_http_only
    assert_cookie_header "user_name=david; path=/; HttpOnly"
    assert_equal({"user_name" => "david"}, @response.cookies)
  end

  def test_multiple_cookies
    get :set_multiple_cookies
    assert_equal 2, @response.cookies.size
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10-Oct-2005 05:00:00 GMT\nlogin=XJ-122; path=/"
    assert_equal({"login" => "XJ-122", "user_name" => "david"}, @response.cookies)
  end

  def test_setting_test_cookie
    assert_nothing_raised { get :access_frozen_cookies }
  end

  def test_expiring_cookie
    get :logout
    assert_cookie_header "user_name=; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT"
    assert_equal({"user_name" => nil}, @response.cookies)
  end

  def test_delete_cookie_with_path
    get :delete_cookie_with_path
    assert_cookie_header "user_name=; path=/beaten; expires=Thu, 01-Jan-1970 00:00:00 GMT"
  end

  def test_cookies_persist_throughout_request
    response = get :authenticate
    assert response.headers["Set-Cookie"] =~ /user_name=david/
  end

  def test_permanent_cookie
    get :set_permanent_cookie
    assert_match /Jamie/, @response.headers["Set-Cookie"]
    assert_match %r(#{20.years.from_now.utc.year}), @response.headers["Set-Cookie"]
  end

  def test_signed_cookie
    get :set_signed_cookie
    assert_equal 45, @controller.send(:cookies).signed[:user_id]
  end

  def test_accessing_nonexistant_signed_cookie_should_not_raise_an_invalid_signature
    get :set_signed_cookie
    assert_nil @controller.send(:cookies).signed[:non_existant_attribute]
  end

  def test_permanent_signed_cookie
    get :set_permanent_signed_cookie
    assert_match %r(#{20.years.from_now.utc.year}), @response.headers["Set-Cookie"]
    assert_equal 100, @controller.send(:cookies).signed[:remember_me]
  end

  def test_delete_and_set_cookie
    get :delete_and_set_cookie
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10-Oct-2005 05:00:00 GMT"
    assert_equal({"user_name" => "david"}, @response.cookies)
  end

  def test_raise_data_overflow
    assert_raise(ActionDispatch::Cookies::CookieOverflow) do
      get :raise_data_overflow
    end
  end

  def test_tampered_cookies
    assert_nothing_raised do
      get :tampered_cookies
      assert_response :success
    end
  end

  def test_raises_argument_error_if_missing_secret
    assert_raise(ArgumentError, nil.inspect) {
      @request.env["action_dispatch.secret_token"] = nil
      get :set_signed_cookie
    }

    assert_raise(ArgumentError, ''.inspect) {
      @request.env["action_dispatch.secret_token"] = ""
      get :set_signed_cookie
    }
  end

  def test_raises_argument_error_if_secret_is_probably_insecure
    assert_raise(ArgumentError, "password".inspect) {
      @request.env["action_dispatch.secret_token"] = "password"
      get :set_signed_cookie
    }

    assert_raise(ArgumentError, "secret".inspect) {
      @request.env["action_dispatch.secret_token"] = "secret"
      get :set_signed_cookie
    }

    assert_raise(ArgumentError, "12345678901234567890123456789".inspect) {
      @request.env["action_dispatch.secret_token"] = "12345678901234567890123456789"
      get :set_signed_cookie
    }
  end

  def test_cookie_with_all_domain_option
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.com; path=/"
  end

  def test_deleting_cookie_with_all_domain_option
    get :delete_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=; domain=.nextangle.com; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT"
  end

  private
    def assert_cookie_header(expected)
      header = @response.headers["Set-Cookie"]
      if header.respond_to?(:to_str)
        assert_equal expected.split("\n").sort, header.split("\n").sort
      else
        assert_equal expected.split("\n"), header
      end
    end
end