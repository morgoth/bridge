require 'abstract_unit'

class Comment
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :id
  def to_key; id ? [id] : nil end
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def name
    @id.nil? ? 'new comment' : "comment ##{@id}"
  end
end

class Sheep
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :id
  def to_key; id ? [id] : nil end
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def name
    @id.nil? ? 'new sheep' : "sheep ##{@id}"
  end
end

class RecordIdentifierTest < Test::Unit::TestCase
  include ActionController::RecordIdentifier

  def setup
    @klass  = Comment
    @record = @klass.new
    @singular = 'comment'
    @plural = 'comments'
    @uncountable = Sheep
  end

  def test_dom_id_with_new_record
    assert_equal "new_#{@singular}", dom_id(@record)
  end

  def test_dom_id_with_new_record_and_prefix
    assert_equal "custom_prefix_#{@singular}", dom_id(@record, :custom_prefix)
  end

  def test_dom_id_with_saved_record
    @record.save
    assert_equal "#{@singular}_1", dom_id(@record)
  end

  def test_dom_id_with_prefix
    @record.save
    assert_equal "edit_#{@singular}_1", dom_id(@record, :edit)
  end

  def test_dom_class
    assert_equal @singular, dom_class(@record)
  end

  def test_dom_class_with_prefix
    assert_equal "custom_prefix_#{@singular}", dom_class(@record, :custom_prefix)
  end
end
