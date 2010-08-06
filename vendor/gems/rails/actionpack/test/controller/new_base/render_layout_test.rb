require 'abstract_unit'

module ControllerLayouts
  class ImplicitController < ::ApplicationController
    self.view_paths = [ActionView::FixtureResolver.new(
      "layouts/application.html.erb" => "Main <%= yield %> Layout",
      "layouts/override.html.erb"    => "Override! <%= yield %>",
      "basic.html.erb"               => "Hello world!",
      "controller_layouts/implicit/layout_false.html.erb" => "hi(layout_false.html.erb)"
    )]

    def index
      render :template => "basic"
    end

    def override
      render :template => "basic", :layout => "override"
    end

    def layout_false
      render :layout => false
    end

    def builder_override
    end
  end

  class ImplicitNameController < ::ApplicationController
    self.view_paths = [ActionView::FixtureResolver.new(
      "layouts/controller_layouts/implicit_name.html.erb" => "Implicit <%= yield %> Layout",
      "basic.html.erb" => "Hello world!"
    )]

    def index
      render :template => "basic"
    end
  end

  class RenderLayoutTest < Rack::TestCase
    test "rendering a normal template, but using the implicit layout" do
      get "/controller_layouts/implicit/index"

      assert_body   "Main Hello world! Layout"
      assert_status 200
    end

    test "rendering a normal template, but using an implicit NAMED layout" do
      get "/controller_layouts/implicit_name/index"

      assert_body "Implicit Hello world! Layout"
      assert_status 200
    end

    test "overriding an implicit layout with render :layout option" do
      get "/controller_layouts/implicit/override"
      assert_body "Override! Hello world!"
    end

  end

  class LayoutOptionsTest < Rack::TestCase
    testing ControllerLayouts::ImplicitController

    test "rendering with :layout => false leaves out the implicit layout" do
      get :layout_false
      assert_response "hi(layout_false.html.erb)"
    end
  end

  class MismatchFormatController < ::ApplicationController
    self.view_paths = [ActionView::FixtureResolver.new(
      "layouts/application.html.erb" => "<html><%= yield %></html>",
      "controller_layouts/mismatch_format/index.js.rjs" => "page[:test].ext",
      "controller_layouts/mismatch_format/implicit.rjs" => "page[:test].ext"      
    )]

    def explicit
      render :layout => "application"
    end
  end

  class MismatchFormatTest < Rack::TestCase
    testing ControllerLayouts::MismatchFormatController

    test "if JS is selected, an HTML template is not also selected" do
      get :index, "format" => "js"
      assert_response "$(\"test\").ext();"
    end

    test "if JS is implicitly selected, an HTML template is not also selected" do
      get :implicit
      assert_response "$(\"test\").ext();"
    end

    test "if an HTML template is explicitly provides for a JS template, an error is raised" do
      assert_raises ActionView::MissingTemplate do
        get :explicit, {}, "action_dispatch.show_exceptions" => false
      end
    end
  end
end
