require "test_helper"
require "table_factories_helper"

class SerializerClaimTest < ActiveSupport::TestCase
  include TableFactoriesHelper

  test "should return default values when not playing" do
    table = table_without_board
    expected = {:maxTricks => 13}
    assert_equal expected, Serializer.new(table).claim(Factory(:user))
  end

  test "should return 12 tricks when played 1" do
    table = table_with_trick
    expected = {:maxTricks => 12}
    assert_equal expected, Serializer.new(table).claim(Factory(:user))
  end
end
