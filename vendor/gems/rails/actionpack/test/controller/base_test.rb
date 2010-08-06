require 'abstract_unit'
require 'logger'
require 'pp' # require 'pp' early to prevent hidden_methods from not picking up the pretty-print methods until too late

# Provide some controller to run the tests on.
module Submodule
  class ContainedEmptyController < ActionController::Base
  end

  class ContainedNonEmptyController < ActionController::Base
    def public_action
      render :nothing => true
    end

    hide_action :hidden_action
    def hidden_action
      raise "Noooo!"
    end

    def another_hidden_action
    end
    hide_action :another_hidden_action
  end

  class SubclassedController < ContainedNonEmptyController
    hide_action :public_action # Hiding it here should not affect the superclass.
  end
end

class EmptyController < ActionController::Base
end

class NonEmptyController < ActionController::Base
  def public_action
    render :nothing => true
  end

  hide_action :hidden_action
  def hidden_action
  end
end

class MethodMissingController < ActionController::Base
  hide_action :shouldnt_be_called
  def shouldnt_be_called
    raise "NO WAY!"
  end

protected

  def method_missing(selector)
    render :text => selector.to_s
  end
end

class AnotherMethodMissingController < ActionController::Base
  cattr_accessor :_exception
  rescue_from Exception, :with => :_exception=

  protected
  def method_missing(*attrs, &block)
    super
  end
end

class DefaultUrlOptionsController < ActionController::Base
  def from_view
    render :inline => "<%= #{params[:route]} %>"
  end

  def default_url_options(options = nil)
    { :host => 'www.override.com', :action => 'new', :locale => 'en' }
  end
end

class UrlOptionsController < ActionController::Base
  def from_view
    render :inline => "<%= #{params[:route]} %>"
  end

  def url_options
    super.merge(:host => 'www.override.com', :action => 'new', :locale => 'en')
  end
end

class RecordIdentifierController < ActionController::Base
end

class ControllerClassTests < ActiveSupport::TestCase
  
  def test_controller_path
    assert_equal 'empty', EmptyController.controller_path
    assert_equal EmptyController.controller_path, EmptyController.new.controller_path
    assert_equal 'submodule/contained_empty', Submodule::ContainedEmptyController.controller_path
    assert_equal Submodule::ContainedEmptyController.controller_path, Submodule::ContainedEmptyController.new.controller_path
  end

  def test_controller_name
    assert_equal 'empty', EmptyController.controller_name
    assert_equal 'contained_empty', Submodule::ContainedEmptyController.controller_name
  end
 
  def test_filter_parameter_logging
    parameters = []
    config = mock(:config => mock(:filter_parameters => parameters))
    Rails.expects(:application).returns(config)

    assert_deprecated do
      Class.new(ActionController::Base) do
        filter_parameter_logging :password
      end
    end

    assert_equal [:password], parameters
  end

  def test_record_identifier
    assert_respond_to RecordIdentifierController.new, :dom_id
    assert_respond_to RecordIdentifierController.new, :dom_class
  end
end

class ControllerInstanceTests < Test::Unit::TestCase
  def setup
    @empty = EmptyController.new
    @contained = Submodule::ContainedEmptyController.new
    @empty_controllers = [@empty, @contained, Submodule::SubclassedController.new]

    @non_empty_controllers = [NonEmptyController.new,
                              Submodule::ContainedNonEmptyController.new]
  end

  def test_action_methods
    @empty_controllers.each do |c|
      assert_equal Set.new, c.class.action_methods, "#{c.controller_path} should be empty!"
    end

    @non_empty_controllers.each do |c|
      assert_equal Set.new(%w(public_action)), c.class.action_methods, "#{c.controller_path} should not be empty!"
    end
  end

  def test_temporary_anonymous_controllers
    name = 'ExamplesController'
    klass = Class.new(ActionController::Base)
    Object.const_set(name, klass)

    controller = klass.new
    assert_equal "examples", controller.controller_path
  end
end

class PerformActionTest < ActionController::TestCase
  def use_controller(controller_class)
    @controller = controller_class.new

    # enable a logger so that (e.g.) the benchmarking stuff runs, so we can get
    # a more accurate simulation of what happens in "real life".
    @controller.logger = Logger.new(nil)

    @request     = ActionController::TestRequest.new
    @response    = ActionController::TestResponse.new
    @request.host = "www.nextangle.com"

    rescue_action_in_public!
  end
  
  def test_process_should_be_precise
    use_controller EmptyController
    exception = assert_raise AbstractController::ActionNotFound do
      get :non_existent
    end
    assert_equal exception.message, "The action 'non_existent' could not be found for EmptyController" 
  end
  
  def test_get_on_priv_should_show_selector
    use_controller MethodMissingController
    get :shouldnt_be_called
    assert_response :success
    assert_equal 'shouldnt_be_called', @response.body
  end

  def test_method_missing_is_not_an_action_name
    use_controller MethodMissingController
    assert !@controller.__send__(:action_method?, 'method_missing')

    get :method_missing
    assert_response :success
    assert_equal 'method_missing', @response.body
  end

  def test_method_missing_should_recieve_symbol
    use_controller AnotherMethodMissingController
    get :some_action
    assert_kind_of NameError, @controller._exception
  end

  def test_get_on_hidden_should_fail
    use_controller NonEmptyController
    assert_raise(ActionController::UnknownAction) { get :hidden_action }
    assert_raise(ActionController::UnknownAction) { get :another_hidden_action }
  end
end

class UrlOptionsTest < ActionController::TestCase
  tests UrlOptionsController

  def setup
    super
    @request.host = 'www.example.com'
    rescue_action_in_public!
  end

  def test_url_options_override
    with_routing do |set|
      set.draw do
        match 'from_view', :to => 'url_options#from_view', :as => :from_view
        match ':controller/:action'
      end

      get :from_view, :route => "from_view_url"

      assert_equal 'http://www.override.com/from_view?locale=en', @response.body
      assert_equal 'http://www.override.com/from_view?locale=en', @controller.send(:from_view_url)
      assert_equal 'http://www.override.com/default_url_options/new?locale=en', @controller.url_for(:controller => 'default_url_options')
    end
  end 

  def test_url_helpers_does_not_become_actions
    with_routing do |set|
      set.draw do
        match "account/overview"
      end

      @controller.class.send(:include, set.url_helpers)
      assert !@controller.class.action_methods.include?("account_overview_path")
    end
  end
end

class DefaultUrlOptionsTest < ActionController::TestCase
  tests DefaultUrlOptionsController

  def setup
    super
    @request.host = 'www.example.com'
    rescue_action_in_public!
  end

  def test_default_url_options_override
    with_routing do |set|
      set.draw do
        match 'from_view', :to => 'default_url_options#from_view', :as => :from_view
        match ':controller/:action'
      end

      get :from_view, :route => "from_view_url"

      assert_equal 'http://www.override.com/from_view?locale=en', @response.body
      assert_equal 'http://www.override.com/from_view?locale=en', @controller.send(:from_view_url)
      assert_equal 'http://www.override.com/default_url_options/new?locale=en', @controller.url_for(:controller => 'default_url_options')
    end
  end

  def test_default_url_options_are_used_in_non_positional_parameters
    with_routing do |set|
      set.draw do
        scope("/:locale") do
          resources :descriptions
        end
        match ':controller/:action'
      end

      get :from_view, :route => "description_path(1)"

      assert_equal '/en/descriptions/1', @response.body
      assert_equal '/en/descriptions', @controller.send(:descriptions_path)
      assert_equal '/pl/descriptions', @controller.send(:descriptions_path, "pl")
      assert_equal '/pl/descriptions', @controller.send(:descriptions_path, :locale => "pl")
      assert_equal '/pl/descriptions.xml', @controller.send(:descriptions_path, "pl", "xml")
      assert_equal '/en/descriptions.xml', @controller.send(:descriptions_path, :format => "xml")
      assert_equal '/en/descriptions/1', @controller.send(:description_path, 1)
      assert_equal '/pl/descriptions/1', @controller.send(:description_path, "pl", 1)
      assert_equal '/pl/descriptions/1', @controller.send(:description_path, 1, :locale => "pl")
      assert_equal '/pl/descriptions/1.xml', @controller.send(:description_path, "pl", 1, "xml")
      assert_equal '/en/descriptions/1.xml', @controller.send(:description_path, 1, :format => "xml")
    end
  end

end

class EmptyUrlOptionsTest < ActionController::TestCase
  tests NonEmptyController

  def setup
    super
    @request.host = 'www.example.com'
    rescue_action_in_public!
  end

  def test_ensure_url_for_works_as_expected_when_called_with_no_options_if_default_url_options_is_not_set
    get :public_action
    assert_equal "http://www.example.com/non_empty/public_action", @controller.url_for
  end

  def test_named_routes_with_path_without_doing_a_request_first
    @controller = EmptyController.new
    @controller.request = @request

    with_routing do |set|
      set.draw do |map|
        resources :things
      end

      assert_equal '/things', @controller.send(:things_path)
    end
  end
end
