# encoding: utf-8
require 'cases/helper'

require 'models/topic'
require 'models/person'

class ConfirmationValidationTest < ActiveModel::TestCase

  def teardown
    Topic.reset_callbacks(:validate)
  end

  def test_no_title_confirmation
    Topic.validates_confirmation_of(:title)

    t = Topic.new(:author_name => "Plutarch")
    assert t.valid?

    t.title_confirmation = "Parallel Lives"
    assert t.invalid?

    t.title_confirmation = nil
    t.title = "Parallel Lives"
    assert t.valid?

    t.title_confirmation = "Parallel Lives"
    assert t.valid?
  end

  def test_title_confirmation
    Topic.validates_confirmation_of(:title)

    t = Topic.new("title" => "We should be confirmed","title_confirmation" => "")
    assert t.invalid?

    t.title_confirmation = "We should be confirmed"
    assert t.valid?
  end

  def test_validates_confirmation_of_for_ruby_class
    Person.validates_confirmation_of :karma

    p = Person.new
    p.karma_confirmation = "None"
    assert p.invalid?

    assert_equal ["doesn't match confirmation"], p.errors[:karma]

    p.karma = "None"
    assert p.valid?
  ensure
    Person.reset_callbacks(:validate)
  end

end
