require 'cases/helper'
require 'models/person'

class ActiveModelI18nTests < ActiveModel::TestCase

  def setup
    I18n.backend = I18n::Backend::Simple.new
  end
  
  def test_translated_model_attributes
    I18n.backend.store_translations 'en', :activemodel => {:attributes => {:person => {:name => 'person name attribute'} } }
    assert_equal 'person name attribute', Person.human_attribute_name('name')
  end

  def test_translated_model_attributes_with_default
    I18n.backend.store_translations 'en', :attributes => { :name => 'name default attribute' }
    assert_equal 'name default attribute', Person.human_attribute_name('name')
  end
  
  def test_translated_model_attributes_with_symbols
    I18n.backend.store_translations 'en', :activemodel => {:attributes => {:person => {:name => 'person name attribute'} } }
    assert_equal 'person name attribute', Person.human_attribute_name(:name)
  end

  def test_translated_model_attributes_with_ancestor
    I18n.backend.store_translations 'en', :activemodel => {:attributes => {:child => {:name => 'child name attribute'} } }
    assert_equal 'child name attribute', Child.human_attribute_name('name')
  end

  def test_translated_model_attributes_with_ancestors_fallback
    I18n.backend.store_translations 'en', :activemodel => {:attributes => {:person => {:name => 'person name attribute'} } }
    assert_equal 'person name attribute', Child.human_attribute_name('name')
  end

  def test_translated_model_names
    I18n.backend.store_translations 'en', :activemodel => {:models => {:person => 'person model'} }
    assert_equal 'person model', Person.model_name.human
  end

  def test_translated_model_names_with_sti
    I18n.backend.store_translations 'en', :activemodel => {:models => {:child => 'child model'} }
    assert_equal 'child model', Child.model_name.human
  end

  def test_translated_model_names_with_ancestors_fallback
    I18n.backend.store_translations 'en', :activemodel => {:models => {:person => 'person model'} }
    assert_equal 'person model', Child.model_name.human
  end
end

