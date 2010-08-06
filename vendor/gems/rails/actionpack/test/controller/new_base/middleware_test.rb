require 'abstract_unit'

module MiddlewareTest
  class MyMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      result = @app.call(env)
      result[1]["Middleware-Test"] = "Success"
      result[1]["Middleware-Order"] = "First"
      result
    end
  end

  class ExclaimerMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      result = @app.call(env)
      result[1]["Middleware-Order"] << "!"
      result
    end
  end

  class MyController < ActionController::Metal
    use MyMiddleware
    middleware.insert_before MyMiddleware, ExclaimerMiddleware

    def index
      self.response_body = "Hello World"
    end
  end

  class InheritedController < MyController
  end

  class ActionsController < ActionController::Metal
    use MyMiddleware, :only => :show
    middleware.insert_before MyMiddleware, ExclaimerMiddleware, :except => :index

    def index
      self.response_body = "index"
    end

    def show
      self.response_body = "show"
    end
  end

  class TestMiddleware < ActiveSupport::TestCase
    def setup
      @app = MyController.action(:index)
    end

    test "middleware that is 'use'd is called as part of the Rack application" do
      result = @app.call(env_for("/"))
      assert_equal "Hello World", RackTestUtils.body_to_string(result[2])
      assert_equal "Success", result[1]["Middleware-Test"]
    end

    test "the middleware stack is exposed as 'middleware' in the controller" do
      result = @app.call(env_for("/"))
      assert_equal "First!", result[1]["Middleware-Order"]
    end

    test "middleware stack accepts only and except as options" do
      result = ActionsController.action(:show).call(env_for("/"))
      assert_equal "First!", result[1]["Middleware-Order"]

      result = ActionsController.action(:index).call(env_for("/"))
      assert_nil result[1]["Middleware-Order"]
    end

    def env_for(url)
      Rack::MockRequest.env_for(url)
    end
  end

  class TestInheritedMiddleware < TestMiddleware
    def setup
      @app = InheritedController.action(:index)
    end
  end
end
