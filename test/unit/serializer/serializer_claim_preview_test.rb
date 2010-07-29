require "test_helper"
require "table_factories_helper"

class SerializerClaimPreviewTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when not claim" do
    table = table_without_board
    expected = {:claimId => 0, :name => "", :tricks => 0, :total => 0, :explanation => "", :acceptEnabled => false, :rejectEnabled => false, :cancelEnabled => false, :visible => false}
    assert_equal expected, Serializer.new(table).claim_preview(Factory(:user))
  end

  #TODO: write more tests
end
