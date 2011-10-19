require 'test_helper'

class Web::SessionTest < ActiveSupport::TestCase
  def setup
    @model = Web::Session.new({})
  end

  include ActiveModel::Lint::Tests
end
