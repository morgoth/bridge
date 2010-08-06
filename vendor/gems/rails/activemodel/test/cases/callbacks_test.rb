require "cases/helper"

class CallbacksTest < ActiveModel::TestCase

  class CallbackValidator
    def around_create(model)
      model.callbacks << :before_around_create
      yield
      model.callbacks << :after_around_create
    end
  end

  class ModelCallbacks
    attr_reader :callbacks
    extend ActiveModel::Callbacks

    define_model_callbacks :create
    define_model_callbacks :initialize, :only => :after

    before_create :before_create
    around_create CallbackValidator.new

    after_create do |model|
      model.callbacks << :after_create
    end

    after_create "@callbacks << :final_callback"

    def initialize(valid=true)
      @callbacks, @valid = [], valid
    end

    def before_create
      @callbacks << :before_create
    end

    def create
      _run_create_callbacks do
        @callbacks << :create
        @valid
      end
    end
  end

  test "complete callback chain" do
    model = ModelCallbacks.new
    model.create
    assert_equal model.callbacks, [ :before_create, :before_around_create, :create,
                                    :after_around_create, :after_create, :final_callback]
  end

  test "after callbacks are always appended" do
    model = ModelCallbacks.new
    model.create
    assert_equal model.callbacks.last, :final_callback
  end

  test "after callbacks are not executed if the block returns false" do
    model = ModelCallbacks.new(false)
    model.create
    assert_equal model.callbacks, [ :before_create, :before_around_create,
                                    :create, :after_around_create]
  end

  test "only selects which types of callbacks should be created" do
    assert !ModelCallbacks.respond_to?(:before_initialize)
    assert !ModelCallbacks.respond_to?(:around_initialize)
    assert_respond_to ModelCallbacks, :after_initialize
  end
end
