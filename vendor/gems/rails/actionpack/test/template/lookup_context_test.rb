require "abstract_unit"
require "abstract_controller/rendering"

ActionView::LookupContext::DetailsKey.class_eval do
  def self.details_keys
    @details_keys
  end
end

class LookupContextTest < ActiveSupport::TestCase
  def setup
    @lookup_context = ActionView::LookupContext.new(FIXTURE_LOAD_PATH, {})
  end

  def teardown
    I18n.locale = :en
    ActionView::LookupContext::DetailsKey.details_keys.clear
  end

  test "process view paths on initialization" do
    assert_kind_of ActionView::PathSet, @lookup_context.view_paths
  end

  test "normalizes details on initialization" do
    assert_equal Mime::SET, @lookup_context.formats
    assert_equal :en, @lookup_context.locale
  end

  test "allows me to freeze and retrieve frozen formats" do
    @lookup_context.formats.freeze
    assert @lookup_context.formats.frozen?
  end

  test "allows me to change some details to execute an specific block of code" do
    formats = Mime::SET
    @lookup_context.update_details(:locale => :pt) do
      assert_equal formats, @lookup_context.formats
      assert_equal :pt, @lookup_context.locale
    end
    assert_equal formats, @lookup_context.formats
    assert_equal :en, @lookup_context.locale
  end

  test "provides getters and setters for formats" do
    @lookup_context.formats = [:html]
    assert_equal [:html], @lookup_context.formats
  end

  test "handles */* formats" do
    @lookup_context.formats = [:"*/*"]
    assert_equal Mime::SET, @lookup_context.formats
  end

  test "adds :html fallback to :js formats" do
    @lookup_context.formats = [:js]
    assert_equal [:js, :html], @lookup_context.formats
  end

  test "provides getters and setters for locale" do
    @lookup_context.locale = :pt
    assert_equal :pt, @lookup_context.locale
  end

  test "changing lookup_context locale, changes I18n.locale" do
    @lookup_context.locale = :pt
    assert_equal :pt, I18n.locale
  end

  test "delegates changing the locale to the I18n configuration object if it contains a lookup_context object" do
    begin
      I18n.config = AbstractController::I18nProxy.new(I18n.config, @lookup_context)
      @lookup_context.locale = :pt
      assert_equal :pt, I18n.locale
      assert_equal :pt, @lookup_context.locale
    ensure
      I18n.config = I18n.config.i18n_config
    end

    assert_equal :pt, I18n.locale
  end

  test "find templates using the given view paths and configured details" do
    template = @lookup_context.find("hello_world", "test")
    assert_equal "Hello world!", template.source

    @lookup_context.locale = :da
    template = @lookup_context.find("hello_world", "test")
    assert_equal "Hey verden", template.source
  end

  test "found templates respects given formats if one cannot be found from template or handler" do
    ActionView::Template::Handlers::ERB.expects(:default_format).returns(nil)
    @lookup_context.formats = [:text]
    template = @lookup_context.find("hello_world", "test")
    assert_equal [:text], template.formats
  end

  test "adds fallbacks to view paths when required" do
    assert_equal 1, @lookup_context.view_paths.size

    @lookup_context.with_fallbacks do
      assert_equal 3, @lookup_context.view_paths.size
      assert @lookup_context.view_paths.include?(ActionView::FileSystemResolver.new(""))
      assert @lookup_context.view_paths.include?(ActionView::FileSystemResolver.new("/"))
    end
  end

  test "add fallbacks just once in nested fallbacks calls" do
    @lookup_context.with_fallbacks do
      @lookup_context.with_fallbacks do
        assert_equal 3, @lookup_context.view_paths.size
      end
    end
  end

  test "generates a new details key for each details hash" do
    keys = []
    keys << @lookup_context.details_key
    assert_equal 1, keys.uniq.size

    @lookup_context.locale = :da
    keys << @lookup_context.details_key
    assert_equal 2, keys.uniq.size

    @lookup_context.locale = :en
    keys << @lookup_context.details_key
    assert_equal 2, keys.uniq.size

    @lookup_context.formats = [:html]
    keys << @lookup_context.details_key
    assert_equal 3, keys.uniq.size

    @lookup_context.formats = nil
    keys << @lookup_context.details_key
    assert_equal 3, keys.uniq.size
  end

  test "gives the key forward to the resolver, so it can be used as cache key" do
    @lookup_context.view_paths = ActionView::FixtureResolver.new("test/_foo.erb" => "Foo")
    template = @lookup_context.find("foo", "test", true)
    assert_equal "Foo", template.source

    # Now we are going to change the template, but it won't change the returned template
    # since we will hit the cache.
    @lookup_context.view_paths.first.hash["test/_foo.erb"] = "Bar"
    template = @lookup_context.find("foo", "test", true)
    assert_equal "Foo", template.source

    # This time we will change the locale. The updated template should be picked since
    # lookup_context generated a new key after we changed the locale.
    @lookup_context.locale = :da
    template = @lookup_context.find("foo", "test", true)
    assert_equal "Bar", template.source

    # Now we will change back the locale and it will still pick the old template.
    # This is expected because lookup_context will reuse the previous key for :en locale.
    @lookup_context.locale = :en
    template = @lookup_context.find("foo", "test", true)
    assert_equal "Foo", template.source

    # Finally, we can expire the cache. And the expected template will be used.
    @lookup_context.view_paths.first.clear_cache
    template = @lookup_context.find("foo", "test", true)
    assert_equal "Bar", template.source
  end
end