# encoding: utf-8
require 'cases/helper'

require 'models/topic'

class ValidatesWithTest < ActiveModel::TestCase

  def teardown
    Topic.reset_callbacks(:validate)
    Topic._validators.clear
  end

  ERROR_MESSAGE = "Validation error from validator"
  OTHER_ERROR_MESSAGE = "Validation error from other validator"

  class ValidatorThatAddsErrors < ActiveModel::Validator
    def validate(record)
      record.errors[:base] << ERROR_MESSAGE
    end
  end

  class OtherValidatorThatAddsErrors < ActiveModel::Validator
    def validate(record)
      record.errors[:base] << OTHER_ERROR_MESSAGE
    end
  end

  class ValidatorThatDoesNotAddErrors < ActiveModel::Validator
    def validate(record)
    end
  end

  class ValidatorThatValidatesOptions < ActiveModel::Validator
    def validate(record)
      if options[:field] == :first_name
        record.errors[:base] << ERROR_MESSAGE
      end
    end
  end

  class ValidatorPerEachAttribute < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "Value is #{value}"
    end
  end

  class ValidatorCheckValidity < ActiveModel::EachValidator
    def check_validity!
      raise "boom!"
    end
  end

  test "vaidation with class that adds errors" do
    Topic.validates_with(ValidatorThatAddsErrors)
    topic = Topic.new
    assert topic.invalid?, "A class that adds errors causes the record to be invalid"
    assert topic.errors[:base].include?(ERROR_MESSAGE)
  end

  test "with a class that returns valid" do
    Topic.validates_with(ValidatorThatDoesNotAddErrors)
    topic = Topic.new
    assert topic.valid?, "A class that does not add errors does not cause the record to be invalid"
  end

  test "with multiple classes" do
    Topic.validates_with(ValidatorThatAddsErrors, OtherValidatorThatAddsErrors)
    topic = Topic.new
    assert topic.invalid?
    assert topic.errors[:base].include?(ERROR_MESSAGE)
    assert topic.errors[:base].include?(OTHER_ERROR_MESSAGE)
  end

  test "with if statements that return false" do
    Topic.validates_with(ValidatorThatAddsErrors, :if => "1 == 2")
    topic = Topic.new
    assert topic.valid?
  end

  test "with if statements that return true" do
    Topic.validates_with(ValidatorThatAddsErrors, :if => "1 == 1")
    topic = Topic.new
    assert topic.invalid?
    assert topic.errors[:base].include?(ERROR_MESSAGE)
  end

  test "with unless statements that return true" do
    Topic.validates_with(ValidatorThatAddsErrors, :unless => "1 == 1")
    topic = Topic.new
    assert topic.valid?
  end

  test "with unless statements that returns false" do
    Topic.validates_with(ValidatorThatAddsErrors, :unless => "1 == 2")
    topic = Topic.new
    assert topic.invalid?
    assert topic.errors[:base].include?(ERROR_MESSAGE)
  end

  test "passes all configuration options to the validator class" do
    topic = Topic.new
    validator = mock()
    validator.expects(:new).with(:foo => :bar, :if => "1 == 1").returns(validator)
    validator.expects(:validate).with(topic)

    Topic.validates_with(validator, :if => "1 == 1", :foo => :bar)
    assert topic.valid?
  end

  test "calls setup method of validator passing in self when validator has setup method" do
    topic = Topic.new
    validator = stub_everything
    validator.stubs(:new).returns(validator)
    validator.stubs(:validate)
    validator.stubs(:respond_to?).with(:setup).returns(true)
    validator.expects(:setup).with(Topic).once
    Topic.validates_with(validator)
    assert topic.valid?
  end

  test "doesn't call setup method of validator when validator has no setup method" do
    topic = Topic.new
    validator = stub_everything
    validator.stubs(:new).returns(validator)
    validator.stubs(:validate)
    validator.stubs(:respond_to?).with(:setup).returns(false)
    validator.expects(:setup).with(Topic).never
    Topic.validates_with(validator)
    assert topic.valid?
  end

  test "validates_with with options" do
    Topic.validates_with(ValidatorThatValidatesOptions, :field => :first_name)
    topic = Topic.new
    assert topic.invalid?
    assert topic.errors[:base].include?(ERROR_MESSAGE)
  end

  test "validates_with each validator" do
    Topic.validates_with(ValidatorPerEachAttribute, :attributes => [:title, :content])
    topic = Topic.new :title => "Title", :content => "Content"
    assert topic.invalid?
    assert_equal ["Value is Title"], topic.errors[:title]
    assert_equal ["Value is Content"], topic.errors[:content]
  end

  test "each validator checks validity" do
    assert_raise RuntimeError do
      Topic.validates_with(ValidatorCheckValidity, :attributes => [:title])
    end
  end

  test "each validator expects attributes to be given" do
    assert_raise RuntimeError do
      Topic.validates_with(ValidatorPerEachAttribute)
    end
  end

  test "each validator skip nil values if :allow_nil is set to true" do
    Topic.validates_with(ValidatorPerEachAttribute, :attributes => [:title, :content], :allow_nil => true)
    topic = Topic.new :content => ""
    assert topic.invalid?
    assert topic.errors[:title].empty?
    assert_equal ["Value is "], topic.errors[:content]
  end

  test "each validator skip blank values if :allow_blank is set to true" do
    Topic.validates_with(ValidatorPerEachAttribute, :attributes => [:title, :content], :allow_blank => true)
    topic = Topic.new :content => ""
    assert topic.valid?
    assert topic.errors[:title].empty?
    assert topic.errors[:content].empty?
  end
end
