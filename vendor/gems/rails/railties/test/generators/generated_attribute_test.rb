require 'generators/generators_test_helper'
require 'rails/generators/generated_attribute'

class GeneratedAttributeTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  def test_field_type_returns_text_field
    %w(integer float decimal string).each do |attribute_type|
      assert_field_type attribute_type, :text_field
    end
  end

  def test_field_type_returns_datetime_select
    %w(datetime timestamp).each do |attribute_type|
      assert_field_type attribute_type, :datetime_select
    end
  end

  def test_field_type_returns_time_select
    assert_field_type :time, :time_select
  end

  def test_field_type_returns_date_select
    assert_field_type :date, :date_select
  end

  def test_field_type_returns_text_area
    assert_field_type :text, :text_area
  end

  def test_field_type_returns_check_box
    assert_field_type :boolean, :check_box
  end

  def test_field_type_with_unknown_type_returns_text_field
    %w(foo bar baz).each do |attribute_type|
      assert_field_type attribute_type, :text_field
    end
  end

  def test_default_value_is_integer
    assert_field_default_value :integer, 1
  end

  def test_default_value_is_float
    assert_field_default_value :float, 1.5
  end

  def test_default_value_is_decimal
    assert_field_default_value :decimal, '9.99'
  end

  def test_default_value_is_datetime
    %w(datetime timestamp time).each do |attribute_type|
      assert_field_default_value attribute_type, Time.now.to_s(:db)
    end
  end

  def test_default_value_is_date
    assert_field_default_value :date, Date.today.to_s(:db)
  end

  def test_default_value_is_string
    assert_field_default_value :string, 'MyString'
  end

  def test_default_value_is_text
    assert_field_default_value :text, 'MyText'
  end

  def test_default_value_is_boolean
    assert_field_default_value :boolean, false
  end

  def test_default_value_is_nil
    %w(references belongs_to).each do |attribute_type|
      assert_field_default_value attribute_type, nil
    end
  end

  def test_default_value_is_empty_string
    %w(foo bar baz).each do |attribute_type|
      assert_field_default_value attribute_type, ''
    end
  end

  def test_human_name
    assert_equal(
      'Full name',
      create_generated_attribute(:string, 'full_name').human_name
    )
  end

  def test_reference_is_true
    %w(references belongs_to).each do |attribute_type|
      assert_equal(
        true,
        create_generated_attribute(attribute_type).reference?
      )
    end
  end

  def test_reference_is_false
    %w(foo bar baz).each do |attribute_type|
      assert_equal(
        false,
        create_generated_attribute(attribute_type).reference?
      )
    end
  end
end
