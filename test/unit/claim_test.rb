require "test_helper"

class ClaimTest < ActiveSupport::TestCase
  setup do
    @claim = Factory.build(:claim)
  end

  test "is valid with valid attributes" do
    @claim.valid?
    notify @claim.errors
  end
end
