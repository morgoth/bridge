require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @session = {}
    @user = Factory(:user)
    @model = @user_session = UserSession.new(@session, :email => @user.email, :password => @user.password)
  end

  test "should be valid with valid attributes" do
    assert @user_session.valid?
  end

  test "should save properly with valid attributes" do
    assert @user_session.save
  end

  test "should be invalid without password" do
    @user_session.password = nil
    assert @user_session.invalid?
  end

  test "should be invalid with a wrong password" do
    @user_session.password = "wrongpassword"
    assert @user_session.invalid?
  end

  test "should be invalid without email" do
    @user_session.email = nil
    assert @user_session.invalid?
  end

  test "should be invalid with non-existing email" do
    @user_session.email = "nonexisting@example.com"
    assert @user_session.invalid?
  end

  test "should strip whitespaces from email before validation" do
    @user_session.email = "   #{@user_session.email}     "
    assert @user_session.valid?
  end

  test "should be email case insensitive" do
    @user_session.email.upcase!
    assert @user_session.valid?
  end

  test "should return correct user when saved" do
    @user_session.save
    assert_equal @user, @user_session.user
  end

  test "should have correct id when saved" do
    @user_session.save
    assert @user.id, @user_session.id
  end

  test "should save user_id to session after save" do
    @user_session.save
    assert_equal @user.id, @session[:user_id]
  end

  test "should delete user_id from session after destroy" do
    @user_session.save
    @user_session.destroy
    assert_nil @session[:user_id]
  end

  test "should not allow to mass assign id attribute" do
    @user_session.attributes = { :id => 666 }
    assert_nil @user_session.id
  end

  test "should not be a new_record after save" do
    @user_session.save
    assert_false @user_session.new_record?
  end

  test "should not be destroyed after initialization" do
    assert_false @user_session.destroyed?
  end

  test "should be destroyed after destroy" do
    @user_session.save
    @user_session.destroy
    assert @user_session.destroyed?
  end

  test "should find UserSession from existing session" do
    @session[:user_id] = @user.id
    user_session = UserSession.find(@session)
    assert_equal @user, user_session.user
  end
end
