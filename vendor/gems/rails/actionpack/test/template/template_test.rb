require "abstract_unit"

if "ruby".encoding_aware?
  # These are the normal settings that will be set up by Railties
  # TODO: Have these tests support other combinations of these values
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
end

class TestERBTemplate < ActiveSupport::TestCase
  ERBHandler = ActionView::Template::Handlers::ERB

  class Context
    def initialize
      @output_buffer = "original"
    end

    def hello
      "Hello"
    end

    def partial
      ActionView::Template.new(
        "<%= @_virtual_path %>",
        "partial",
        ERBHandler,
        :virtual_path => "partial"
      )
    end

    def logger
      require "logger"
      Logger.new(STDERR)
    end

    def my_buffer
      @output_buffer
    end
  end

  def new_template(body = "<%= hello %>", handler = ERBHandler, details = {})
    ActionView::Template.new(body, "hello template", ERBHandler, {:virtual_path => "hello"})
  end

  def render(locals = {})
    @template.render(@obj, locals)
  end

  def setup
    @obj = Context.new
  end

  def test_basic_template
    @template = new_template
    assert_equal "Hello", render
  end

  def test_locals
    @template = new_template("<%= my_local %>")
    assert_equal "I'm a local", render(:my_local => "I'm a local")
  end

  def test_restores_buffer
    @template = new_template
    assert_equal "Hello", render
    assert_equal "original", @obj.my_buffer
  end

  def test_virtual_path
    @template = new_template("<%= @_virtual_path %>" \
                             "<%= partial.render(self, {}) %>" \
                             "<%= @_virtual_path %>")
    assert_equal "hellopartialhello", render
  end

  if "ruby".encoding_aware?
    def test_resulting_string_is_utf8
      @template = new_template
      assert_equal Encoding::UTF_8, render.encoding
    end

    def test_no_magic_comment_word_with_utf_8
      @template = new_template("hello \u{fc}mlat")
      assert_equal Encoding::UTF_8, render.encoding
      assert_equal "hello \u{fc}mlat", render
    end

    # This test ensures that if the default_external
    # is set to something other than UTF-8, we don't
    # get any errors and get back a UTF-8 String.
    def test_default_external_works
      Encoding.default_external = "ISO-8859-1"
      @template = new_template("hello \xFCmlat")
      assert_equal Encoding::UTF_8, render.encoding
      assert_equal "hello \u{fc}mlat", render
    ensure
      Encoding.default_external = "UTF-8"
    end

    def test_encoding_can_be_specified_with_magic_comment
      @template = new_template("# encoding: ISO-8859-1\nhello \xFCmlat")
      assert_equal Encoding::UTF_8, render.encoding
      assert_equal "\nhello \u{fc}mlat", render
    end

    # TODO: This is currently handled inside ERB. The case of explicitly
    # lying about encodings via the normal Rails API should be handled
    # inside Rails.
    def test_lying_with_magic_comment
      assert_raises(ActionView::Template::Error) do
        @template = new_template("# encoding: UTF-8\nhello \xFCmlat")
        render
      end
    end

    def test_encoding_can_be_specified_with_magic_comment_in_erb
      with_external_encoding Encoding::UTF_8 do
        @template = new_template("<%# encoding: ISO-8859-1 %>hello \xFCmlat")
        result = render
        assert_equal Encoding::UTF_8, render.encoding
        assert_equal "hello \u{fc}mlat", render
      end
    end

    def test_error_when_template_isnt_valid_utf8
      assert_raises(ActionView::Template::Error, /\xFC/) do
        @template = new_template("hello \xFCmlat")
        render
      end
    end

    def with_external_encoding(encoding)
      old, Encoding.default_external = Encoding.default_external, encoding
      yield
    ensure
      Encoding.default_external = old
    end
  end
end