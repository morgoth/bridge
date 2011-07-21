require 'test_helper'

class Website::SessionTest < ActiveSupport::TestCase
  def setup
    @model = Website::Session.new({})
  end

  include ActiveModel::Lint::Tests
end
