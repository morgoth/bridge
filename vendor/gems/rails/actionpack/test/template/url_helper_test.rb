# encoding: utf-8
require 'abstract_unit'
require 'active_support/ordered_hash'
require 'controller/fake_controllers'

class UrlHelperTest < ActiveSupport::TestCase

  # In a few cases, the helper proxies to 'controller'
  # or request.
  #
  # In those cases, we'll set up a simple mock
  attr_accessor :controller, :request

  routes = ActionDispatch::Routing::RouteSet.new
  routes.draw do
    match "/" => "foo#bar"
    match "/other" => "foo#other"
  end

  include routes.url_helpers

  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Assertions::DomAssertions
  include ActionView::Context
  include RenderERBUtils

  # self.default_url_options = {:host => "www.example.com"}

  # TODO: This shouldn't be needed (see template.rb:53)
  def assigns
    {}
  end

  def hash_for(opts = [])
    ActiveSupport::OrderedHash[*([:controller, "foo", :action, "bar"].concat(opts))]
  end
  alias url_hash hash_for

  def test_url_for_does_not_escape_urls
    assert_equal "/?a=b&c=d", url_for(hash_for([:a, :b, :c, :d]))
  end

  def test_url_for_with_back
    referer = 'http://www.example.com/referer'
    @controller = Struct.new(:request).new(Struct.new(:env).new({"HTTP_REFERER" => referer}))

    assert_equal 'http://www.example.com/referer', url_for(:back)
  end

  def test_url_for_with_back_and_no_referer
    @controller = Struct.new(:request).new(Struct.new(:env).new({}))
    assert_equal 'javascript:history.back()', url_for(:back)
  end

  # todo: missing test cases
  def test_button_to_with_straight_url
    assert_dom_equal "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\"><div><input type=\"submit\" value=\"Hello\" /></div></form>", button_to("Hello", "http://www.example.com")
  end

  def test_button_to_with_query
    assert_dom_equal "<form method=\"post\" action=\"http://www.example.com/q1=v1&amp;q2=v2\" class=\"button_to\"><div><input type=\"submit\" value=\"Hello\" /></div></form>", button_to("Hello", "http://www.example.com/q1=v1&q2=v2")
  end

  def test_button_to_with_html_safe_URL
    assert_dom_equal "<form method=\"post\" action=\"http://www.example.com/q1=v1&amp;q2=v2\" class=\"button_to\"><div><input type=\"submit\" value=\"Hello\" /></div></form>", button_to("Hello", "http://www.example.com/q1=v1&amp;q2=v2".html_safe)
  end

  def test_button_to_with_query_and_no_name
    assert_dom_equal "<form method=\"post\" action=\"http://www.example.com?q1=v1&amp;q2=v2\" class=\"button_to\"><div><input type=\"submit\" value=\"http://www.example.com?q1=v1&amp;q2=v2\" /></div></form>", button_to(nil, "http://www.example.com?q1=v1&q2=v2")
  end

  def test_button_to_with_javascript_confirm
    assert_dom_equal(
      "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\"><div><input data-confirm=\"Are you sure?\" type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :confirm => "Are you sure?")
    )
  end

  def test_button_to_with_remote_and_javascript_confirm
    assert_dom_equal(
      "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\" data-remote=\"true\"><div><input data-confirm=\"Are you sure?\" type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :remote => true, :confirm => "Are you sure?")
    )
  end

  def test_button_to_with_remote_false
    assert_dom_equal(
      "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\"><div><input type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :remote => false)
    )
  end

  def test_button_to_enabled_disabled
    assert_dom_equal(
      "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\"><div><input type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :disabled => false)
    )
    assert_dom_equal(
      "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\"><div><input disabled=\"disabled\" type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :disabled => true)
    )
  end

  def test_button_to_with_method_delete
    assert_dom_equal(
      "<form method=\"post\" action=\"http://www.example.com\" class=\"button_to\"><div><input type=\"hidden\" name=\"_method\" value=\"delete\" /><input type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :method => :delete)
    )
  end

  def test_button_to_with_method_get
    assert_dom_equal(
      "<form method=\"get\" action=\"http://www.example.com\" class=\"button_to\"><div><input type=\"submit\" value=\"Hello\" /></div></form>",
      button_to("Hello", "http://www.example.com", :method => :get)
    )
  end

  def test_link_tag_with_straight_url
    assert_dom_equal "<a href=\"http://www.example.com\">Hello</a>", link_to("Hello", "http://www.example.com")
  end

  def test_link_tag_without_host_option
    assert_dom_equal(%q{<a href="/">Test Link</a>}, link_to('Test Link', url_hash))
  end

  def test_link_tag_with_host_option
    hash = hash_for([:host, "www.example.com"])
    expected = %q{<a href="http://www.example.com/">Test Link</a>}
    assert_dom_equal(expected, link_to('Test Link', hash))
  end

  def test_link_tag_with_query
    expected = %{<a href="http://www.example.com?q1=v1&amp;q2=v2">Hello</a>}
    assert_dom_equal expected, link_to("Hello", "http://www.example.com?q1=v1&q2=v2")
  end

  def test_link_tag_with_query_and_no_name
    expected = %{<a href="http://www.example.com?q1=v1&amp;q2=v2">http://www.example.com?q1=v1&amp;q2=v2</a>}
    assert_dom_equal expected, link_to(nil, "http://www.example.com?q1=v1&q2=v2")
  end

  def test_link_tag_with_back
    env = {"HTTP_REFERER" => "http://www.example.com/referer"}
    @controller = Struct.new(:request).new(Struct.new(:env).new(env))
    expected = %{<a href="#{env["HTTP_REFERER"]}">go back</a>}
    assert_dom_equal expected, link_to('go back', :back)
  end

  def test_link_tag_with_back_and_no_referer
    @controller = Struct.new(:request).new(Struct.new(:env).new({}))
    link = link_to('go back', :back)
    assert_dom_equal %{<a href="javascript:history.back()">go back</a>}, link
  end

  def test_link_tag_with_img
    link = link_to("<img src='/favicon.jpg' />".html_safe, "/")
    expected = %{<a href="/"><img src='/favicon.jpg' /></a>}
    assert_dom_equal expected, link
  end

  def test_link_with_nil_html_options
    link = link_to("Hello", url_hash, nil)
    assert_dom_equal %{<a href="/">Hello</a>}, link
  end

  def test_link_tag_with_custom_onclick
    link = link_to("Hello", "http://www.example.com", :onclick => "alert('yay!')")
    expected = %{<a href="http://www.example.com" onclick="alert('yay!')">Hello</a>}
    assert_dom_equal expected, link
  end

  def test_link_tag_with_javascript_confirm
    assert_dom_equal(
      "<a href=\"http://www.example.com\" data-confirm=\"Are you sure?\">Hello</a>",
      link_to("Hello", "http://www.example.com", :confirm => "Are you sure?")
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com\" data-confirm=\"You can't possibly be sure, can you?\">Hello</a>",
      link_to("Hello", "http://www.example.com", :confirm => "You can't possibly be sure, can you?")
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com\" data-confirm=\"You can't possibly be sure,\n can you?\">Hello</a>",
      link_to("Hello", "http://www.example.com", :confirm => "You can't possibly be sure,\n can you?")
    )
  end

  def test_link_to_with_remote
    assert_dom_equal(
      "<a href=\"http://www.example.com\" data-remote=\"true\">Hello</a>",
      link_to("Hello", "http://www.example.com", :remote => true)
    )
  end

  def test_link_to_with_remote_false
    assert_dom_equal(
      "<a href=\"http://www.example.com\">Hello</a>",
      link_to("Hello", "http://www.example.com", :remote => false)
    )
  end

  def test_link_tag_using_post_javascript
    assert_dom_equal(
      "<a href='http://www.example.com' data-method=\"post\" rel=\"nofollow\">Hello</a>",
      link_to("Hello", "http://www.example.com", :method => :post)
    )
  end

  def test_link_tag_using_delete_javascript
    assert_dom_equal(
      "<a href='http://www.example.com' rel=\"nofollow\" data-method=\"delete\">Destroy</a>",
      link_to("Destroy", "http://www.example.com", :method => :delete)
    )
  end

  def test_link_tag_using_delete_javascript_and_href
    assert_dom_equal(
      "<a href='\#' rel=\"nofollow\" data-method=\"delete\">Destroy</a>",
      link_to("Destroy", "http://www.example.com", :method => :delete, :href => '#')
    )
  end

  def test_link_tag_using_post_javascript_and_confirm
    assert_dom_equal(
      "<a href=\"http://www.example.com\" data-method=\"post\" rel=\"nofollow\" data-confirm=\"Are you serious?\">Hello</a>",
      link_to("Hello", "http://www.example.com", :method => :post, :confirm => "Are you serious?")
    )
  end

  def test_link_tag_using_delete_javascript_and_href_and_confirm
    assert_dom_equal(
      "<a href='\#' rel=\"nofollow\" data-confirm=\"Are you serious?\" data-method=\"delete\">Destroy</a>",
      link_to("Destroy", "http://www.example.com", :method => :delete, :href => '#', :confirm => "Are you serious?"),
      "When specifying url, form should be generated with it, but not this.href"
    )
  end

  def test_link_tag_using_block_in_erb
    out = render_erb %{<%= link_to('/') do %>Example site<% end %>}
    assert_equal '<a href="/">Example site</a>', out
  end

  def test_link_to_unless
    assert_equal "Showing", link_to_unless(true, "Showing", url_hash)

    assert_dom_equal %{<a href="/">Listing</a>},
      link_to_unless(false, "Listing", url_hash)

    assert_equal "Showing", link_to_unless(true, "Showing", url_hash)

    assert_equal "<strong>Showing</strong>",
      link_to_unless(true, "Showing", url_hash) { |name|
        "<strong>#{name}</strong>"
      }

    assert_equal "<strong>Showing</strong>",
      link_to_unless(true, "Showing", url_hash) { |name|
        "<strong>#{name}</strong>"
      }

    assert_equal "test",
      link_to_unless(true, "Showing", url_hash) {
        "test"
      }
  end

  def test_link_to_if
    assert_equal "Showing", link_to_if(false, "Showing", url_hash)
    assert_dom_equal %{<a href="/">Listing</a>}, link_to_if(true, "Listing", url_hash)
    assert_equal "Showing", link_to_if(false, "Showing", url_hash)
  end

  def request_for_url(url)
    env = Rack::MockRequest.env_for("http://www.example.com#{url}")
    ActionDispatch::Request.new(env)
  end

  def test_current_page_with_simple_url
    @request = request_for_url("/")
    assert current_page?(url_hash)
    assert current_page?("http://www.example.com/")
  end

  def test_current_page_ignoring_params
    @request = request_for_url("/?order=desc&page=1")

    assert current_page?(url_hash)
    assert current_page?("http://www.example.com/")
  end

  def test_current_page_with_params_that_match
    @request = request_for_url("/?order=desc&page=1")

    assert current_page?(hash_for([:order, "desc", :page, "1"]))
    assert current_page?("http://www.example.com/?order=desc&page=1")
  end

  def test_link_unless_current
    @request = request_for_url("/")

    assert_equal "Showing",
      link_to_unless_current("Showing", url_hash)
    assert_equal "Showing",
      link_to_unless_current("Showing", "http://www.example.com/")

    @request = request_for_url("/?order=desc")

    assert_equal "Showing",
      link_to_unless_current("Showing", url_hash)
    assert_equal "Showing",
      link_to_unless_current("Showing", "http://www.example.com/")

    @request = request_for_url("/?order=desc&page=1")

    assert_equal "Showing",
      link_to_unless_current("Showing", hash_for([:order, 'desc', :page, '1']))
    assert_equal "Showing",
      link_to_unless_current("Showing", "http://www.example.com/?order=desc&page=1")

    @request = request_for_url("/?order=desc")

    assert_equal %{<a href="/?order=asc">Showing</a>},
      link_to_unless_current("Showing", hash_for([:order, :asc]))
    assert_equal %{<a href="http://www.example.com/?order=asc">Showing</a>},
      link_to_unless_current("Showing", "http://www.example.com/?order=asc")

    @request = request_for_url("/?order=desc")
    assert_equal %{<a href="/?order=desc&amp;page=2\">Showing</a>},
      link_to_unless_current("Showing", hash_for([:order, "desc", :page, 2]))
    assert_equal %{<a href="http://www.example.com/?order=desc&amp;page=2">Showing</a>},
      link_to_unless_current("Showing", "http://www.example.com/?order=desc&page=2")

    @request = request_for_url("/show")

    assert_equal %{<a href="/">Listing</a>},
      link_to_unless_current("Listing", url_hash)
    assert_equal %{<a href="http://www.example.com/">Listing</a>},
      link_to_unless_current("Listing", "http://www.example.com/")
  end

  def test_mail_to
    assert_dom_equal "<a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>", mail_to("david@loudthinking.com")
    assert_dom_equal "<a href=\"mailto:david@loudthinking.com\">David Heinemeier Hansson</a>", mail_to("david@loudthinking.com", "David Heinemeier Hansson")
    assert_dom_equal(
      "<a class=\"admin\" href=\"mailto:david@loudthinking.com\">David Heinemeier Hansson</a>",
      mail_to("david@loudthinking.com", "David Heinemeier Hansson", "class" => "admin")
    )
    assert_equal mail_to("david@loudthinking.com", "David Heinemeier Hansson", "class" => "admin"),
                 mail_to("david@loudthinking.com", "David Heinemeier Hansson", :class => "admin")
  end

  def test_mail_to_with_javascript
    snippet = mail_to("me@domain.com", "My email", :encode => "javascript")
    assert_dom_equal "<script type=\"text/javascript\">eval(decodeURIComponent('%64%6f%63%75%6d%65%6e%74%2e%77%72%69%74%65%28%27%3c%61%20%68%72%65%66%3d%22%6d%61%69%6c%74%6f%3a%6d%65%40%64%6f%6d%61%69%6e%2e%63%6f%6d%22%3e%4d%79%20%65%6d%61%69%6c%3c%2f%61%3e%27%29%3b'))</script>", snippet
    assert snippet.html_safe?
  end

  def test_mail_to_with_javascript_unicode
    snippet = mail_to("unicode@example.com", "únicode", :encode => "javascript")
    assert_dom_equal "<script type=\"text/javascript\">eval(decodeURIComponent('%64%6f%63%75%6d%65%6e%74%2e%77%72%69%74%65%28%27%3c%61%20%68%72%65%66%3d%22%6d%61%69%6c%74%6f%3a%75%6e%69%63%6f%64%65%40%65%78%61%6d%70%6c%65%2e%63%6f%6d%22%3e%c3%ba%6e%69%63%6f%64%65%3c%2f%61%3e%27%29%3b'))</script>", snippet
    assert snippet.html_safe
  end

  def test_mail_with_options
    assert_dom_equal(
      %(<a href="mailto:me@example.com?cc=ccaddress%40example.com&amp;bcc=bccaddress%40example.com&amp;body=This%20is%20the%20body%20of%20the%20message.&amp;subject=This%20is%20an%20example%20email">My email</a>),
      mail_to("me@example.com", "My email", :cc => "ccaddress@example.com", :bcc => "bccaddress@example.com", :subject => "This is an example email", :body => "This is the body of the message.")
    )
  end

  def test_mail_to_with_img
    assert_dom_equal %(<a href="mailto:feedback@example.com"><img src="/feedback.png" /></a>),
      mail_to('feedback@example.com', '<img src="/feedback.png" />'.html_safe)
  end

  def test_mail_to_with_hex
    assert_dom_equal "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d\">My email</a>", mail_to("me@domain.com", "My email", :encode => "hex")
    assert_dom_equal "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d\">&#109;&#101;&#64;&#100;&#111;&#109;&#97;&#105;&#110;&#46;&#99;&#111;&#109;</a>", mail_to("me@domain.com", nil, :encode => "hex")
  end

  def test_mail_to_with_replace_options
    assert_dom_equal "<a href=\"mailto:wolfgang@stufenlos.net\">wolfgang(at)stufenlos(dot)net</a>", mail_to("wolfgang@stufenlos.net", nil, :replace_at => "(at)", :replace_dot => "(dot)")
    assert_dom_equal "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d\">&#109;&#101;&#40;&#97;&#116;&#41;&#100;&#111;&#109;&#97;&#105;&#110;&#46;&#99;&#111;&#109;</a>", mail_to("me@domain.com", nil, :encode => "hex", :replace_at => "(at)")
    assert_dom_equal "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d\">My email</a>", mail_to("me@domain.com", "My email", :encode => "hex", :replace_at => "(at)")
    assert_dom_equal "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d\">&#109;&#101;&#40;&#97;&#116;&#41;&#100;&#111;&#109;&#97;&#105;&#110;&#40;&#100;&#111;&#116;&#41;&#99;&#111;&#109;</a>", mail_to("me@domain.com", nil, :encode => "hex", :replace_at => "(at)", :replace_dot => "(dot)")
    assert_dom_equal "<script type=\"text/javascript\">eval(decodeURIComponent('%64%6f%63%75%6d%65%6e%74%2e%77%72%69%74%65%28%27%3c%61%20%68%72%65%66%3d%22%6d%61%69%6c%74%6f%3a%6d%65%40%64%6f%6d%61%69%6e%2e%63%6f%6d%22%3e%4d%79%20%65%6d%61%69%6c%3c%2f%61%3e%27%29%3b'))</script>", mail_to("me@domain.com", "My email", :encode => "javascript", :replace_at => "(at)", :replace_dot => "(dot)")
    assert_dom_equal "<script type=\"text/javascript\">eval(decodeURIComponent('%64%6f%63%75%6d%65%6e%74%2e%77%72%69%74%65%28%27%3c%61%20%68%72%65%66%3d%22%6d%61%69%6c%74%6f%3a%6d%65%40%64%6f%6d%61%69%6e%2e%63%6f%6d%22%3e%6d%65%28%61%74%29%64%6f%6d%61%69%6e%28%64%6f%74%29%63%6f%6d%3c%2f%61%3e%27%29%3b'))</script>", mail_to("me@domain.com", nil, :encode => "javascript", :replace_at => "(at)", :replace_dot => "(dot)")
  end

  # TODO: button_to looks at this ... why?
  def protect_against_forgery?
    false
  end

  private
    def sort_query_string_params(uri)
      path, qs = uri.split('?')
      qs = qs.split('&amp;').sort.join('&amp;') if qs
      qs ? "#{path}?#{qs}" : path
    end
end

class UrlHelperControllerTest < ActionController::TestCase
  class UrlHelperController < ActionController::Base
    test_routes do |map|
      match 'url_helper_controller_test/url_helper/show/:id',
        :to => 'url_helper_controller_test/url_helper#show',
        :as => :show

      match 'url_helper_controller_test/url_helper/profile/:name',
        :to => 'url_helper_controller_test/url_helper#show',
        :as => :profile

      match 'url_helper_controller_test/url_helper/show_named_route',
        :to => 'url_helper_controller_test/url_helper#show_named_route',
        :as => :show_named_route

      map.connect ":controller/:action/:id"
      # match "/:controller(/:action(/:id))"

      match 'url_helper_controller_test/url_helper/normalize_recall_params',
        :to => UrlHelperController.action(:normalize_recall),
        :as => :normalize_recall_params
    end

    def show
      if params[:name]
        render :inline => 'ok'
      else
        redirect_to profile_path(params[:id])
      end
    end

    def show_url_for
      render :inline => "<%= url_for :controller => 'url_helper_controller_test/url_helper', :action => 'show_url_for' %>"
    end

    def show_overriden_url_for
      render :inline => "<%= url_for params.merge(:controller => 'url_helper_controller_test/url_helper', :action => 'show_url_for') %>"
    end

    def show_named_route
      render :inline => "<%= show_named_route_#{params[:kind]} %>"
    end

    def nil_url_for
      render :inline => '<%= url_for(nil) %>'
    end

    def normalize_recall_params
      render :inline => '<%= normalize_recall_params_path %>'
    end

    def recall_params_not_changed
      render :inline => '<%= url_for(:action => :show_url_for) %>'
    end

    def rescue_action(e) raise e end
  end

  tests UrlHelperController

  def test_url_for_shows_only_path
    get :show_url_for
    assert_equal '/url_helper_controller_test/url_helper/show_url_for', @response.body
  end

  def test_overriden_url_for_shows_only_path
    get :show_overriden_url_for
    assert_equal '/url_helper_controller_test/url_helper/show_url_for', @response.body
  end

  def test_named_route_url_shows_host_and_path
    get :show_named_route, :kind => 'url'
    assert_equal 'http://test.host/url_helper_controller_test/url_helper/show_named_route',
      @response.body
  end

  def test_named_route_path_shows_only_path
    get :show_named_route, :kind => 'path'
    assert_equal '/url_helper_controller_test/url_helper/show_named_route', @response.body
  end

  def test_url_for_nil_returns_current_path
    get :nil_url_for
    assert_equal '/url_helper_controller_test/url_helper/nil_url_for', @response.body
  end

  def test_named_route_should_show_host_and_path_using_controller_default_url_options
    class << @controller
      def default_url_options(options = nil)
        {:host => 'testtwo.host'}
      end
    end

    get :show_named_route, :kind => 'url'
    assert_equal 'http://testtwo.host/url_helper_controller_test/url_helper/show_named_route', @response.body
  end

  def test_recall_params_should_be_normalized
    get :normalize_recall_params
    assert_equal '/url_helper_controller_test/url_helper/normalize_recall_params', @response.body
  end

  def test_recall_params_should_not_be_changed
    get :recall_params_not_changed
    assert_equal '/url_helper_controller_test/url_helper/show_url_for', @response.body
  end

  def test_recall_params_should_normalize_id
    get :show, :id => '123'
    assert_equal 302, @response.status
    assert_equal 'http://test.host/url_helper_controller_test/url_helper/profile/123', @response.location

    get :show, :name => '123'
    assert_equal 'ok', @response.body
  end
end

class TasksController < ActionController::Base
  test_routes do
    resources :tasks
  end

  def index
    render_default
  end

  def show
    render_default
  end

  def rescue_action(e) raise e end

  protected
    def render_default
      render :inline =>
        "<%= link_to_unless_current(\"tasks\", tasks_path) %>\n" +
        "<%= link_to_unless_current(\"tasks\", tasks_url) %>"
    end
end

class LinkToUnlessCurrentWithControllerTest < ActionController::TestCase
  tests TasksController

  def test_link_to_unless_current_to_current
    get :index
    assert_equal "tasks\ntasks", @response.body
  end

  def test_link_to_unless_current_shows_link
    get :show, :id => 1
    assert_equal "<a href=\"/tasks\">tasks</a>\n" +
      "<a href=\"#{@request.protocol}#{@request.host_with_port}/tasks\">tasks</a>",
      @response.body
  end
end

class Workshop
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :id

  def initialize(id)
    @id = id
  end

  def persisted?
    id.present?
  end

  def to_s
    id.to_s
  end
end

class Session
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :id, :workshop_id

  def initialize(id)
    @id = id
  end

  def persisted?
    id.present?
  end

  def to_s
    id.to_s
  end
end

class WorkshopsController < ActionController::Base
  test_routes do
    resources :workshops do
      resources :sessions
    end
  end

  def index
    @workshop = Workshop.new(nil)
    render :inline => "<%= url_for(@workshop) %>\n<%= link_to('Workshop', @workshop) %>"
  end

  def show
    @workshop = Workshop.new(params[:id])
    render :inline => "<%= url_for(@workshop) %>\n<%= link_to('Workshop', @workshop) %>"
  end

  def rescue_action(e) raise e end
end

class SessionsController < ActionController::Base
  test_routes do
    resources :workshops do
      resources :sessions
    end
  end

  def index
    @workshop = Workshop.new(params[:workshop_id])
    @session = Session.new(nil)
    render :inline => "<%= url_for([@workshop, @session]) %>\n<%= link_to('Session', [@workshop, @session]) %>"
  end

  def show
    @workshop = Workshop.new(params[:workshop_id])
    @session = Session.new(params[:id])
    render :inline => "<%= url_for([@workshop, @session]) %>\n<%= link_to('Session', [@workshop, @session]) %>"
  end

  def rescue_action(e) raise e end
end

class PolymorphicControllerTest < ActionController::TestCase
  def test_new_resource
    @controller = WorkshopsController.new

    get :index
    assert_equal "/workshops\n<a href=\"/workshops\">Workshop</a>", @response.body
  end

  def test_existing_resource
    @controller = WorkshopsController.new

    get :show, :id => 1
    assert_equal "/workshops/1\n<a href=\"/workshops/1\">Workshop</a>", @response.body
  end

  def test_new_nested_resource
    @controller = SessionsController.new

    get :index, :workshop_id => 1
    assert_equal "/workshops/1/sessions\n<a href=\"/workshops/1/sessions\">Session</a>", @response.body
  end
  
  def test_existing_nested_resource
    @controller = SessionsController.new
  
    get :show, :workshop_id => 1, :id => 1
    assert_equal "/workshops/1/sessions/1\n<a href=\"/workshops/1/sessions/1\">Session</a>", @response.body
  end
end
