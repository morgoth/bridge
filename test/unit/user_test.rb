require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = Factory.build(:user)
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

  test "should not be authenticated with a wrong password" do
    @user.save!
    assert_false @user.authenticated?("wrongpass")
  end

  test "should save without assigning a new password" do
    @user.save!
    @user.email = "alice@example.com"
    @user.save!
  end

  test "should be invalid with too short password" do
    @user.password = @user.password_confirmation = "123"
    assert_false @user.valid?
  end

  test "should be invalid with too long password" do
    @user.password = @user.password_confirmation = "l#{'o' * 40}ngpass"
    assert @user.invalid?
  end

  test "should be invalid without password confirmation" do
    @user.password_confirmation = nil
    assert @user.invalid?
  end

  test "should be invalid with incorrect password confirmation" do
    @user.password = "secret"
    @user.password_confirmation = "retsecay"
    assert @user.invalid?
  end

  test "should validate uniqueness of email" do
    @user.save!
    user = Factory.build(:user, :email => @user.email)
    assert user.invalid?
  end

  test "should be invalid with mispelled email" do
    @user.email = "im.not.an.email"
    assert @user.invalid?
  end
end
