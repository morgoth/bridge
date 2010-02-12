require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = @user = Factory.build(:user)
  end

  test "should be valid with all attributes" do
    assert @user.valid?
  end

  test "should save properly" do
    @user.save!
  end

  test "should be authenticated with correct password" do
    @user.save!
    @user.authenticated?(@password)
  end
end
