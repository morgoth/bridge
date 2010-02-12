require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = @user = Factory.build(:user)
    @password = @user.password
  end

  test "should be valid with all valid attributes" do
    assert @user.valid?
  end

  test "should save properly" do
    @user.save!
  end

  test "should be authenticated with the correct password" do
    @user.save!
    assert @user.authenticated?(@password)
  end

  test "should save without assigning a new password" do
    @user.save!
    @user.email = "alice@example.com"
    @user.save!
  end

  test "should not be valid with too short password" do
    @user.password = @user.password_confirmation = "123"
    assert_false @user.valid?
  end
end
