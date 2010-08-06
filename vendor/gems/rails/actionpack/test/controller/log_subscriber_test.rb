require "abstract_unit"
require "active_support/log_subscriber/test_helper"
require "action_controller/log_subscriber"

module Another
  class LogSubscribersController < ActionController::Base
    def show
      render :nothing => true
    end

    def redirector
      redirect_to "http://foo.bar/"
    end

    def data_sender
      send_data "cool data", :filename => "file.txt"
    end

    def xfile_sender
      send_file File.expand_path("company.rb", FIXTURE_LOAD_PATH), :x_sendfile => true
    end

    def file_sender
      send_file File.expand_path("company.rb", FIXTURE_LOAD_PATH)
    end

    def with_fragment_cache
      render :inline => "<%= cache('foo'){ 'bar' } %>"
    end

    def with_page_cache
      cache_page("Super soaker", "/index.html")
      render :nothing => true
    end
  end
end

class ACLogSubscriberTest < ActionController::TestCase
  tests Another::LogSubscribersController
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super

    @old_logger = ActionController::Base.logger

    @cache_path = File.expand_path('../temp/test_cache', File.dirname(__FILE__))
    ActionController::Base.page_cache_directory = @cache_path
    @controller.cache_store = :file_store, @cache_path
    ActionController::LogSubscriber.attach_to :action_controller
  end

  def teardown
    super
    ActiveSupport::LogSubscriber.log_subscribers.clear
    FileUtils.rm_rf(@cache_path)
    ActionController::Base.logger = @old_logger
  end

  def set_logger(logger)
    ActionController::Base.logger = logger
  end

  def test_start_processing
    get :show
    wait
    assert_equal 2, logs.size
    assert_equal "Processing by Another::LogSubscribersController#show as HTML", logs.first
  end

  def test_process_action
    get :show
    wait
    assert_equal 2, logs.size
    assert_match /Completed/, logs.last
    assert_match /200 OK/, logs.last
  end

  def test_process_action_without_parameters
    get :show
    wait
    assert_nil logs.detect {|l| l =~ /Parameters/ }
  end

  def test_process_action_with_parameters
    get :show, :id => '10'
    wait

    assert_equal 3, logs.size
    assert_equal 'Parameters: {"id"=>"10"}', logs[1]
  end

  def test_process_action_with_view_runtime
    get :show
    wait
    assert_match /\(Views: [\d\.]+ms\)/, logs[1]
  end

  def test_process_action_with_filter_parameters
    @request.env["action_dispatch.parameter_filter"] = [:lifo, :amount]

    get :show, :lifo => 'Pratik', :amount => '420', :step => '1'
    wait

    params = logs[1]
    assert_match /"amount"=>"\[FILTERED\]"/, params
    assert_match /"lifo"=>"\[FILTERED\]"/, params
    assert_match /"step"=>"1"/, params
  end

  def test_redirect_to
    get :redirector
    wait

    assert_equal 3, logs.size
    assert_equal "Redirected to http://foo.bar/", logs[1]
  end

  def test_send_data
    get :data_sender
    wait

    assert_equal 3, logs.size
    assert_match /Sent data file\.txt/, logs[1]
  end

  def test_send_file
    get :file_sender
    wait

    assert_equal 3, logs.size
    assert_match /Sent file/, logs[1]
    assert_match /test\/fixtures\/company\.rb/, logs[1]
  end

  def test_send_xfile
    assert_deprecated { get :xfile_sender }
    wait

    assert_equal 3, logs.size
    assert_match /Sent file/, logs[1]
    assert_match /test\/fixtures\/company\.rb/, logs[1]
  end

  def test_with_fragment_cache
    @controller.config.perform_caching = true
    get :with_fragment_cache
    wait

    assert_equal 4, logs.size
    assert_match /Exist fragment\? views\/foo/, logs[1]
    assert_match /Write fragment views\/foo/, logs[2]
  ensure
    @controller.config.perform_caching = true
  end

  def test_with_page_cache
    @controller.config.perform_caching = true
    get :with_page_cache
    wait

    assert_equal 3, logs.size
    assert_match /Write page/, logs[1]
    assert_match /\/index\.html/, logs[1]
  ensure
    @controller.config.perform_caching = true
  end

  def logs
    @logs ||= @logger.logged(:info)
  end
end
