require "cases/helper"
require 'models/minimalistic'
require 'models/developer'
require 'models/auto_id'
require 'models/computer'
require 'models/topic'
require 'models/company'
require 'models/category'
require 'models/reply'

class AttributeMethodsTest < ActiveRecord::TestCase
  fixtures :topics, :developers, :companies, :computers
  
  def setup
    @old_matchers = ActiveRecord::Base.send(:attribute_method_matchers).dup
    @target = Class.new(ActiveRecord::Base)
    @target.table_name = 'topics'
  end

  def teardown
    ActiveRecord::Base.send(:attribute_method_matchers).clear
    ActiveRecord::Base.send(:attribute_method_matchers).concat(@old_matchers)
  end

  def test_attribute_present
    t = Topic.new
    t.title = "hello there!"
    t.written_on = Time.now
    assert t.attribute_present?("title")
    assert t.attribute_present?("written_on")
    assert !t.attribute_present?("content")
  end

  def test_attribute_keys_on_new_instance
    t = Topic.new
    assert_equal nil, t.title, "The topics table has a title column, so it should be nil"
    assert_raise(NoMethodError) { t.title2 }
  end

  def test_boolean_attributes
    assert ! Topic.find(1).approved?
    assert Topic.find(2).approved?
  end

  def test_set_attributes
    topic = Topic.find(1)
    topic.attributes = { "title" => "Budget", "author_name" => "Jason" }
    topic.save
    assert_equal("Budget", topic.title)
    assert_equal("Jason", topic.author_name)
    assert_equal(topics(:first).author_email_address, Topic.find(1).author_email_address)
  end

  def test_set_attributes_without_hash
    topic = Topic.new
    assert_nothing_raised { topic.attributes = '' }
  end

  def test_integers_as_nil
    test = AutoId.create('value' => '')
    assert_nil AutoId.find(test.id).value
  end

  def test_set_attributes_with_block
    topic = Topic.new do |t|
      t.title       = "Budget"
      t.author_name = "Jason"
    end

    assert_equal("Budget", topic.title)
    assert_equal("Jason", topic.author_name)
  end

  def test_respond_to?
    topic = Topic.find(1)
    assert_respond_to topic, "title"
    assert_respond_to topic, "title?"
    assert_respond_to topic, "title="
    assert_respond_to topic, :title
    assert_respond_to topic, :title?
    assert_respond_to topic, :title=
    assert_respond_to topic, "author_name"
    assert_respond_to topic, "attribute_names"
    assert !topic.respond_to?("nothingness")
    assert !topic.respond_to?(:nothingness)
  end

  def test_array_content
    topic = Topic.new
    topic.content = %w( one two three )
    topic.save

    assert_equal(%w( one two three ), Topic.find(topic.id).content)
  end

  def test_read_attributes_before_type_cast
    category = Category.new({:name=>"Test categoty", :type => nil})
    category_attrs = {"name"=>"Test categoty", "type" => nil, "categorizations_count" => nil}
    assert_equal category_attrs , category.attributes_before_type_cast
  end

  if current_adapter?(:MysqlAdapter)
    def test_read_attributes_before_type_cast_on_boolean
      bool = Booleantest.create({ "value" => false })
      assert_equal "0", bool.reload.attributes_before_type_cast["value"]
    end
  end

  def test_read_attributes_before_type_cast_on_datetime
    developer = Developer.find(:first)
    # Oracle adapter returns Time before type cast
    unless current_adapter?(:OracleAdapter)
      assert_equal developer.created_at.to_s(:db) , developer.attributes_before_type_cast["created_at"]
    else
      assert_equal developer.created_at.to_s(:db) , developer.attributes_before_type_cast["created_at"].to_s(:db)

      developer.created_at = "345643456"
      assert_equal developer.created_at_before_type_cast, "345643456"
      assert_equal developer.created_at, nil

      developer.created_at = "2010-03-21T21:23:32+01:00"
      assert_equal developer.created_at_before_type_cast, "2010-03-21T21:23:32+01:00"
      assert_equal developer.created_at, Time.parse("2010-03-21T21:23:32+01:00")
    end
  end

  def test_hash_content
    topic = Topic.new
    topic.content = { "one" => 1, "two" => 2 }
    topic.save

    assert_equal 2, Topic.find(topic.id).content["two"]

    topic.content_will_change!
    topic.content["three"] = 3
    topic.save

    assert_equal 3, Topic.find(topic.id).content["three"]
  end

  def test_update_array_content
    topic = Topic.new
    topic.content = %w( one two three )

    topic.content.push "four"
    assert_equal(%w( one two three four ), topic.content)

    topic.save

    topic = Topic.find(topic.id)
    topic.content << "five"
    assert_equal(%w( one two three four five ), topic.content)
  end

  def test_case_sensitive_attributes_hash
    # DB2 is not case-sensitive
    return true if current_adapter?(:DB2Adapter)

    assert_equal @loaded_fixtures['computers']['workstation'].to_hash, Computer.find(:first).attributes
  end

  def test_hashes_not_mangled
    new_topic = { :title => "New Topic" }
    new_topic_values = { :title => "AnotherTopic" }

    topic = Topic.new(new_topic)
    assert_equal new_topic[:title], topic.title

    topic.attributes= new_topic_values
    assert_equal new_topic_values[:title], topic.title
  end

  def test_create_through_factory
    topic = Topic.create("title" => "New Topic")
    topicReloaded = Topic.find(topic.id)
    assert_equal(topic, topicReloaded)
  end

  def test_write_attribute
    topic = Topic.new
    topic.send(:write_attribute, :title, "Still another topic")
    assert_equal "Still another topic", topic.title

    topic.send(:write_attribute, "title", "Still another topic: part 2")
    assert_equal "Still another topic: part 2", topic.title
  end

  def test_read_attribute
    topic = Topic.new
    topic.title = "Don't change the topic"
    assert_equal "Don't change the topic", topic.send(:read_attribute, "title")
    assert_equal "Don't change the topic", topic["title"]

    assert_equal "Don't change the topic", topic.send(:read_attribute, :title)
    assert_equal "Don't change the topic", topic[:title]
  end

  def test_read_attribute_when_false
    topic = topics(:first)
    topic.approved = false
    assert !topic.approved?, "approved should be false"
    topic.approved = "false"
    assert !topic.approved?, "approved should be false"
  end

  def test_read_attribute_when_true
    topic = topics(:first)
    topic.approved = true
    assert topic.approved?, "approved should be true"
    topic.approved = "true"
    assert topic.approved?, "approved should be true"
  end

  def test_read_write_boolean_attribute
    topic = Topic.new
    # puts ""
    # puts "New Topic"
    # puts topic.inspect
    topic.approved = "false"
    # puts "Expecting false"
    # puts topic.inspect
    assert !topic.approved?, "approved should be false"
    topic.approved = "false"
    # puts "Expecting false"
    # puts topic.inspect
    assert !topic.approved?, "approved should be false"
    topic.approved = "true"
    # puts "Expecting true"
    # puts topic.inspect
    assert topic.approved?, "approved should be true"
    topic.approved = "true"
    # puts "Expecting true"
    # puts topic.inspect
    assert topic.approved?, "approved should be true"
    # puts ""
  end

  def test_query_attribute_string
    [nil, "", " "].each do |value|
      assert_equal false, Topic.new(:author_name => value).author_name?
    end

    assert_equal true, Topic.new(:author_name => "Name").author_name?
  end

  def test_query_attribute_number
    [nil, 0, "0"].each do |value|
      assert_equal false, Developer.new(:salary => value).salary?
    end

    assert_equal true, Developer.new(:salary => 1).salary?
    assert_equal true, Developer.new(:salary => "1").salary?
  end

  def test_query_attribute_boolean
    [nil, "", false, "false", "f", 0].each do |value|
      assert_equal false, Topic.new(:approved => value).approved?
    end

    [true, "true", "1", 1].each do |value|
      assert_equal true, Topic.new(:approved => value).approved?
    end
  end

  def test_query_attribute_with_custom_fields
    object = Company.find_by_sql(<<-SQL).first
      SELECT c1.*, c2.ruby_type as string_value, c2.rating as int_value
        FROM companies c1, companies c2
       WHERE c1.firm_id = c2.id
         AND c1.id = 2
    SQL

    assert_equal "Firm", object.string_value
    assert object.string_value?

    object.string_value = "  "
    assert !object.string_value?

    assert_equal 1, object.int_value.to_i
    assert object.int_value?

    object.int_value = "0"
    assert !object.int_value?
  end

  def test_non_attribute_access_and_assignment
    topic = Topic.new
    assert !topic.respond_to?("mumbo")
    assert_raise(NoMethodError) { topic.mumbo }
    assert_raise(NoMethodError) { topic.mumbo = 5 }
  end

  def test_undeclared_attribute_method_does_not_affect_respond_to_and_method_missing
    topic = @target.new(:title => 'Budget')
    assert topic.respond_to?('title')
    assert_equal 'Budget', topic.title
    assert !topic.respond_to?('title_hello_world')
    assert_raise(NoMethodError) { topic.title_hello_world }
  end

  def test_declared_prefixed_attribute_method_affects_respond_to_and_method_missing
    topic = @target.new(:title => 'Budget')
    %w(default_ title_).each do |prefix|
      @target.class_eval "def #{prefix}attribute(*args) args end"
      @target.attribute_method_prefix prefix

      meth = "#{prefix}title"
      assert topic.respond_to?(meth)
      assert_equal ['title'], topic.send(meth)
      assert_equal ['title', 'a'], topic.send(meth, 'a')
      assert_equal ['title', 1, 2, 3], topic.send(meth, 1, 2, 3)
    end
  end

  def test_declared_suffixed_attribute_method_affects_respond_to_and_method_missing
    topic = @target.new(:title => 'Budget')
    %w(_default _title_default _it! _candidate= able?).each do |suffix|
      @target.class_eval "def attribute#{suffix}(*args) args end"
      @target.attribute_method_suffix suffix

      meth = "title#{suffix}"
      assert topic.respond_to?(meth)
      assert_equal ['title'], topic.send(meth)
      assert_equal ['title', 'a'], topic.send(meth, 'a')
      assert_equal ['title', 1, 2, 3], topic.send(meth, 1, 2, 3)
    end
  end

  def test_declared_affixed_attribute_method_affects_respond_to_and_method_missing
    topic = @target.new(:title => 'Budget')
    [['mark_', '_for_update'], ['reset_', '!'], ['default_', '_value?']].each do |prefix, suffix|
      @target.class_eval "def #{prefix}attribute#{suffix}(*args) args end"
      @target.attribute_method_affix({ :prefix => prefix, :suffix => suffix })

      meth = "#{prefix}title#{suffix}"
      assert topic.respond_to?(meth)
      assert_equal ['title'], topic.send(meth)
      assert_equal ['title', 'a'], topic.send(meth, 'a')
      assert_equal ['title', 1, 2, 3], topic.send(meth, 1, 2, 3)
    end
  end

  def test_should_unserialize_attributes_for_frozen_records
    myobj = {:value1 => :value2}
    topic = Topic.create("content" => myobj)
    topic.freeze
    assert_equal myobj, topic.content
  end

  def test_typecast_attribute_from_select_to_false
    topic = Topic.create(:title => 'Budget')
    # Oracle does not support boolean expressions in SELECT
    if current_adapter?(:OracleAdapter)
      topic = Topic.find(:first, :select => "topics.*, 0 as is_test")
    else
      topic = Topic.find(:first, :select => "topics.*, 1=2 as is_test")
    end
    assert !topic.is_test?
  end

  def test_typecast_attribute_from_select_to_true
    topic = Topic.create(:title => 'Budget')
    # Oracle does not support boolean expressions in SELECT
    if current_adapter?(:OracleAdapter)
      topic = Topic.find(:first, :select => "topics.*, 1 as is_test")
    else
      topic = Topic.find(:first, :select => "topics.*, 2=2 as is_test")
    end
    assert topic.is_test?
  end

  def test_kernel_methods_not_implemented_in_activerecord
    %w(test name display y).each do |method|
      assert !ActiveRecord::Base.instance_method_already_implemented?(method), "##{method} is defined"
    end
  end

  def test_defined_kernel_methods_implemented_in_model
    %w(test name display y).each do |method|
      klass = Class.new ActiveRecord::Base
      klass.class_eval "def #{method}() 'defined #{method}' end"
      assert klass.instance_method_already_implemented?(method), "##{method} is not defined"
    end
  end

  def test_defined_kernel_methods_implemented_in_model_abstract_subclass
    %w(test name display y).each do |method|
      abstract = Class.new ActiveRecord::Base
      abstract.class_eval "def #{method}() 'defined #{method}' end"
      abstract.abstract_class = true
      klass = Class.new abstract
      assert klass.instance_method_already_implemented?(method), "##{method} is not defined"
    end
  end

  def test_raises_dangerous_attribute_error_when_defining_activerecord_method_in_model
    %w(save create_or_update).each do |method|
      klass = Class.new ActiveRecord::Base
      klass.class_eval "def #{method}() 'defined #{method}' end"
      assert_raise ActiveRecord::DangerousAttributeError do
        klass.instance_method_already_implemented?(method)
      end
    end
  end

  def test_only_time_related_columns_are_meant_to_be_cached_by_default
    expected = %w(datetime timestamp time date).sort
    assert_equal expected, ActiveRecord::Base.attribute_types_cached_by_default.map(&:to_s).sort
  end

  def test_declaring_attributes_as_cached_adds_them_to_the_attributes_cached_by_default
    default_attributes = Topic.cached_attributes
    Topic.cache_attributes :replies_count
    expected = default_attributes + ["replies_count"]
    assert_equal expected.sort, Topic.cached_attributes.sort
    Topic.instance_variable_set "@cached_attributes", nil
  end

  def test_time_related_columns_are_actually_cached
    column_types = %w(datetime timestamp time date).map(&:to_sym)
    column_names = Topic.columns.select{|c| column_types.include?(c.type) }.map(&:name)

    assert_equal column_names.sort, Topic.cached_attributes.sort
    assert_equal time_related_columns_on_topic.sort, Topic.cached_attributes.sort
  end

  def test_accessing_cached_attributes_caches_the_converted_values_and_nothing_else
    t = topics(:first)
    cache = t.instance_variable_get "@attributes_cache"

    assert_not_nil cache
    assert cache.empty?

    all_columns = Topic.columns.map(&:name)
    cached_columns = time_related_columns_on_topic
    uncached_columns =  all_columns - cached_columns

    all_columns.each do |attr_name|
      attribute_gets_cached = Topic.cache_attribute?(attr_name)
      val = t.send attr_name unless attr_name == "type"
      if attribute_gets_cached
        assert cached_columns.include?(attr_name)
        assert_equal val, cache[attr_name]
      else
        assert uncached_columns.include?(attr_name)
        assert !cache.include?(attr_name)
      end
    end
  end

  def test_time_attributes_are_retrieved_in_current_time_zone
    in_time_zone "Pacific Time (US & Canada)" do
      utc_time = Time.utc(2008, 1, 1)
      record   = @target.new
      record[:written_on] = utc_time
      assert_equal utc_time, record.written_on # record.written on is equal to (i.e., simultaneous with) utc_time
      assert_kind_of ActiveSupport::TimeWithZone, record.written_on # but is a TimeWithZone
      assert_equal ActiveSupport::TimeZone["Pacific Time (US & Canada)"], record.written_on.time_zone # and is in the current Time.zone
      assert_equal Time.utc(2007, 12, 31, 16), record.written_on.time # and represents time values adjusted accordingly
    end
  end

  def test_setting_time_zone_aware_attribute_to_utc
    in_time_zone "Pacific Time (US & Canada)" do
      utc_time = Time.utc(2008, 1, 1)
      record   = @target.new
      record.written_on = utc_time
      assert_equal utc_time, record.written_on
      assert_equal ActiveSupport::TimeZone["Pacific Time (US & Canada)"], record.written_on.time_zone
      assert_equal Time.utc(2007, 12, 31, 16), record.written_on.time
    end
  end

  def test_setting_time_zone_aware_attribute_in_other_time_zone
    utc_time = Time.utc(2008, 1, 1)
    cst_time = utc_time.in_time_zone("Central Time (US & Canada)")
    in_time_zone "Pacific Time (US & Canada)" do
      record   = @target.new
      record.written_on = cst_time
      assert_equal utc_time, record.written_on
      assert_equal ActiveSupport::TimeZone["Pacific Time (US & Canada)"], record.written_on.time_zone
      assert_equal Time.utc(2007, 12, 31, 16), record.written_on.time
    end
  end

  def test_setting_time_zone_aware_attribute_with_string
    utc_time = Time.utc(2008, 1, 1)
    (-11..13).each do |timezone_offset|
      time_string = utc_time.in_time_zone(timezone_offset).to_s
      in_time_zone "Pacific Time (US & Canada)" do
        record   = @target.new
        record.written_on = time_string
        assert_equal Time.zone.parse(time_string), record.written_on
        assert_equal ActiveSupport::TimeZone["Pacific Time (US & Canada)"], record.written_on.time_zone
        assert_equal Time.utc(2007, 12, 31, 16), record.written_on.time
      end
    end
  end

  def test_setting_time_zone_aware_attribute_to_blank_string_returns_nil
    in_time_zone "Pacific Time (US & Canada)" do
      record   = @target.new
      record.written_on = ' '
      assert_nil record.written_on
    end
  end

  def test_setting_time_zone_aware_attribute_interprets_time_zone_unaware_string_in_time_zone
    time_string = 'Tue Jan 01 00:00:00 2008'
    (-11..13).each do |timezone_offset|
      in_time_zone timezone_offset do
        record   = @target.new
        record.written_on = time_string
        assert_equal Time.zone.parse(time_string), record.written_on
        assert_equal ActiveSupport::TimeZone[timezone_offset], record.written_on.time_zone
        assert_equal Time.utc(2008, 1, 1), record.written_on.time
      end
    end
  end

  def test_setting_time_zone_aware_attribute_in_current_time_zone
    utc_time = Time.utc(2008, 1, 1)
    in_time_zone "Pacific Time (US & Canada)" do
      record   = @target.new
      record.written_on = utc_time.in_time_zone
      assert_equal utc_time, record.written_on
      assert_equal ActiveSupport::TimeZone["Pacific Time (US & Canada)"], record.written_on.time_zone
      assert_equal Time.utc(2007, 12, 31, 16), record.written_on.time
    end
  end

  def test_setting_time_zone_conversion_for_attributes_should_write_value_on_class_variable
    Topic.skip_time_zone_conversion_for_attributes = [:field_a]
    Minimalistic.skip_time_zone_conversion_for_attributes = [:field_b]
    
    assert_equal [:field_a], Topic.skip_time_zone_conversion_for_attributes 
    assert_equal [:field_b], Minimalistic.skip_time_zone_conversion_for_attributes 
  end

  def test_read_attributes_respect_access_control
    privatize("title")

    topic = @target.new(:title => "The pros and cons of programming naked.")
    assert !topic.respond_to?(:title)
    exception = assert_raise(NoMethodError) { topic.title }
    assert_equal "Attempt to call private method", exception.message
    assert_equal "I'm private", topic.send(:title)
  end

  def test_write_attributes_respect_access_control
    privatize("title=(value)")

    topic = @target.new
    assert !topic.respond_to?(:title=)
    exception = assert_raise(NoMethodError) { topic.title = "Pants"}
    assert_equal "Attempt to call private method", exception.message
    topic.send(:title=, "Very large pants")
  end

  def test_question_attributes_respect_access_control
    privatize("title?")

    topic = @target.new(:title => "Isaac Newton's pants")
    assert !topic.respond_to?(:title?)
    exception = assert_raise(NoMethodError) { topic.title? }
    assert_equal "Attempt to call private method", exception.message
    assert topic.send(:title?)
  end

  def test_bulk_update_respects_access_control
    privatize("title=(value)")

    assert_raise(ActiveRecord::UnknownAttributeError) { topic = @target.new(:title => "Rants about pants") }
    assert_raise(ActiveRecord::UnknownAttributeError) { @target.new.attributes = { :title => "Ants in pants" } }
  end

  def test_read_attribute_overwrites_private_method_not_considered_implemented
    # simulate a model with a db column that shares its name an inherited
    # private method (e.g. Object#system)
    #
    Object.class_eval do
      private
      def title; "private!"; end
    end
    assert !@target.instance_method_already_implemented?(:title)
    topic = @target.new
    assert_nil topic.title

    Object.send(:undef_method, :title) # remove test method from object
  end


  private
  def time_related_columns_on_topic
    Topic.columns.select{|c| [:time, :date, :datetime, :timestamp].include?(c.type)}.map(&:name)
  end

  def in_time_zone(zone)
    old_zone  = Time.zone
    old_tz    = ActiveRecord::Base.time_zone_aware_attributes

    Time.zone = zone ? ActiveSupport::TimeZone[zone] : nil
    ActiveRecord::Base.time_zone_aware_attributes = !zone.nil?
    yield
  ensure
    Time.zone = old_zone
    ActiveRecord::Base.time_zone_aware_attributes = old_tz
  end

  def privatize(method_signature)
    @target.class_eval <<-private_method
      private
      def #{method_signature}
        "I'm private"
      end
    private_method
  end
end
