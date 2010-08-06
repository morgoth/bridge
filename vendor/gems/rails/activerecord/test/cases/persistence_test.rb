require "cases/helper"
require 'models/post'
require 'models/author'
require 'models/topic'
require 'models/reply'
require 'models/category'
require 'models/company'
require 'models/developer'
require 'models/project'
require 'models/minimalistic'
require 'models/warehouse_thing'
require 'models/parrot'
require 'models/minivan'
require 'models/loose_person'
require 'rexml/document'
require 'active_support/core_ext/exception'

class PersistencesTest < ActiveRecord::TestCase

  fixtures :topics, :companies, :developers, :projects, :computers, :accounts, :minimalistics, 'warehouse-things', :authors, :categorizations, :categories, :posts, :minivans

  # Oracle UPDATE does not support ORDER BY
  unless current_adapter?(:OracleAdapter)
    def test_update_all_ignores_order_without_limit_from_association
      author = authors(:david)
      assert_nothing_raised do
        assert_equal author.posts_with_comments_and_categories.length, author.posts_with_comments_and_categories.update_all([ "body = ?", "bulk update!" ])
      end
    end

    def test_update_all_with_order_and_limit_updates_subset_only
      author = authors(:david)
      assert_nothing_raised do
        assert_equal 1, author.posts_sorted_by_id_limited.size
        assert_equal 2, author.posts_sorted_by_id_limited.find(:all, :limit => 2).size
        assert_equal 1, author.posts_sorted_by_id_limited.update_all([ "body = ?", "bulk update!" ])
        assert_equal "bulk update!", posts(:welcome).body
        assert_not_equal "bulk update!", posts(:thinking).body
      end
    end
  end

  def test_update_many
    topic_data = { 1 => { "content" => "1 updated" }, 2 => { "content" => "2 updated" } }
    updated = Topic.update(topic_data.keys, topic_data.values)

    assert_equal 2, updated.size
    assert_equal "1 updated", Topic.find(1).content
    assert_equal "2 updated", Topic.find(2).content
  end

  def test_delete_all
    assert Topic.count > 0

    assert_equal Topic.count, Topic.delete_all
  end

  def test_update_by_condition
    Topic.update_all "content = 'bulk updated!'", ["approved = ?", true]
    assert_equal "Have a nice day", Topic.find(1).content
    assert_equal "bulk updated!", Topic.find(2).content
  end

  def test_increment_attribute
    assert_equal 50, accounts(:signals37).credit_limit
    accounts(:signals37).increment! :credit_limit
    assert_equal 51, accounts(:signals37, :reload).credit_limit

    accounts(:signals37).increment(:credit_limit).increment!(:credit_limit)
    assert_equal 53, accounts(:signals37, :reload).credit_limit
  end

  def test_increment_nil_attribute
    assert_nil topics(:first).parent_id
    topics(:first).increment! :parent_id
    assert_equal 1, topics(:first).parent_id
  end

  def test_increment_attribute_by
    assert_equal 50, accounts(:signals37).credit_limit
    accounts(:signals37).increment! :credit_limit, 5
    assert_equal 55, accounts(:signals37, :reload).credit_limit

    accounts(:signals37).increment(:credit_limit, 1).increment!(:credit_limit, 3)
    assert_equal 59, accounts(:signals37, :reload).credit_limit
  end

  def test_destroy_all
    conditions = "author_name = 'Mary'"
    topics_by_mary = Topic.all(:conditions => conditions, :order => 'id')
    assert ! topics_by_mary.empty?

    assert_difference('Topic.count', -topics_by_mary.size) do
      destroyed = Topic.destroy_all(conditions).sort_by(&:id)
      assert_equal topics_by_mary, destroyed
      assert destroyed.all? { |topic| topic.frozen? }, "destroyed topics should be frozen"
    end
  end

  def test_destroy_many
    clients = Client.find([2, 3], :order => 'id')

    assert_difference('Client.count', -2) do
      destroyed = Client.destroy([2, 3]).sort_by(&:id)
      assert_equal clients, destroyed
      assert destroyed.all? { |client| client.frozen? }, "destroyed clients should be frozen"
    end
  end

  def test_delete_many
    original_count = Topic.count
    Topic.delete(deleting = [1, 2])
    assert_equal original_count - deleting.size, Topic.count
  end

  def test_decrement_attribute
    assert_equal 50, accounts(:signals37).credit_limit

    accounts(:signals37).decrement!(:credit_limit)
    assert_equal 49, accounts(:signals37, :reload).credit_limit

    accounts(:signals37).decrement(:credit_limit).decrement!(:credit_limit)
    assert_equal 47, accounts(:signals37, :reload).credit_limit
  end

  def test_decrement_attribute_by
    assert_equal 50, accounts(:signals37).credit_limit
    accounts(:signals37).decrement! :credit_limit, 5
    assert_equal 45, accounts(:signals37, :reload).credit_limit

    accounts(:signals37).decrement(:credit_limit, 1).decrement!(:credit_limit, 3)
    assert_equal 41, accounts(:signals37, :reload).credit_limit
  end

  def test_create
    topic = Topic.new
    topic.title = "New Topic"
    topic.save
    topic_reloaded = Topic.find(topic.id)
    assert_equal("New Topic", topic_reloaded.title)
  end

  def test_save!
    topic = Topic.new(:title => "New Topic")
    assert topic.save!

    reply = WrongReply.new
    assert_raise(ActiveRecord::RecordInvalid) { reply.save! }
  end

  def test_save_null_string_attributes
    topic = Topic.find(1)
    topic.attributes = { "title" => "null", "author_name" => "null" }
    topic.save!
    topic.reload
    assert_equal("null", topic.title)
    assert_equal("null", topic.author_name)
  end

  def test_save_nil_string_attributes
    topic = Topic.find(1)
    topic.title = nil
    topic.save!
    topic.reload
    assert_nil topic.title
  end

  def test_save_for_record_with_only_primary_key
    minimalistic = Minimalistic.new
    assert_nothing_raised { minimalistic.save }
  end

  def test_save_for_record_with_only_primary_key_that_is_provided
    assert_nothing_raised { Minimalistic.create!(:id => 2) }
  end

  def test_create_many
    topics = Topic.create([ { "title" => "first" }, { "title" => "second" }])
    assert_equal 2, topics.size
    assert_equal "first", topics.first.title
  end

  def test_create_columns_not_equal_attributes
    topic = Topic.new
    topic.title = 'Another New Topic'
    topic.send :write_attribute, 'does_not_exist', 'test'
    assert_nothing_raised { topic.save }
  end

  def test_create_through_factory_with_block
    topic = Topic.create("title" => "New Topic") do |t|
      t.author_name = "David"
    end
    topicReloaded = Topic.find(topic.id)
    assert_equal("New Topic", topic.title)
    assert_equal("David", topic.author_name)
  end

  def test_create_many_through_factory_with_block
    topics = Topic.create([ { "title" => "first" }, { "title" => "second" }]) do |t|
      t.author_name = "David"
    end
    assert_equal 2, topics.size
    topic1, topic2 = Topic.find(topics[0].id), Topic.find(topics[1].id)
    assert_equal "first", topic1.title
    assert_equal "David", topic1.author_name
    assert_equal "second", topic2.title
    assert_equal "David", topic2.author_name
  end

  def test_update
    topic = Topic.new
    topic.title = "Another New Topic"
    topic.written_on = "2003-12-12 23:23:00"
    topic.save
    topicReloaded = Topic.find(topic.id)
    assert_equal("Another New Topic", topicReloaded.title)

    topicReloaded.title = "Updated topic"
    topicReloaded.save

    topicReloadedAgain = Topic.find(topic.id)

    assert_equal("Updated topic", topicReloadedAgain.title)
  end

  def test_update_columns_not_equal_attributes
    topic = Topic.new
    topic.title = "Still another topic"
    topic.save

    topicReloaded = Topic.find(topic.id)
    topicReloaded.title = "A New Topic"
    topicReloaded.send :write_attribute, 'does_not_exist', 'test'
    assert_nothing_raised { topicReloaded.save }
  end

  def test_update_for_record_with_only_primary_key
    minimalistic = minimalistics(:first)
    assert_nothing_raised { minimalistic.save }
  end

  def test_delete
    topic = Topic.find(1)
    assert_equal topic, topic.delete, 'topic.delete did not return self'
    assert topic.frozen?, 'topic not frozen after delete'
    assert_raise(ActiveRecord::RecordNotFound) { Topic.find(topic.id) }
  end

  def test_delete_doesnt_run_callbacks
    Topic.find(1).delete
    assert_not_nil Topic.find(2)
  end

  def test_destroy
    topic = Topic.find(1)
    assert_equal topic, topic.destroy, 'topic.destroy did not return self'
    assert topic.frozen?, 'topic not frozen after destroy'
    assert_raise(ActiveRecord::RecordNotFound) { Topic.find(topic.id) }
  end

  def test_record_not_found_exception
    assert_raise(ActiveRecord::RecordNotFound) { topicReloaded = Topic.find(99999) }
  end

  def test_update_all
    assert_equal Topic.count, Topic.update_all("content = 'bulk updated!'")
    assert_equal "bulk updated!", Topic.find(1).content
    assert_equal "bulk updated!", Topic.find(2).content

    assert_equal Topic.count, Topic.update_all(['content = ?', 'bulk updated again!'])
    assert_equal "bulk updated again!", Topic.find(1).content
    assert_equal "bulk updated again!", Topic.find(2).content

    assert_equal Topic.count, Topic.update_all(['content = ?', nil])
    assert_nil Topic.find(1).content
  end

  def test_update_all_with_hash
    assert_not_nil Topic.find(1).last_read
    assert_equal Topic.count, Topic.update_all(:content => 'bulk updated with hash!', :last_read => nil)
    assert_equal "bulk updated with hash!", Topic.find(1).content
    assert_equal "bulk updated with hash!", Topic.find(2).content
    assert_nil Topic.find(1).last_read
    assert_nil Topic.find(2).last_read
  end

  def test_update_all_with_non_standard_table_name
    assert_equal 1, WarehouseThing.update_all(['value = ?', 0], ['id = ?', 1])
    assert_equal 0, WarehouseThing.find(1).value
  end

  def test_delete_new_record
    client = Client.new
    client.delete
    assert client.frozen?
  end

  def test_delete_record_with_associations
    client = Client.find(3)
    client.delete
    assert client.frozen?
    assert_kind_of Firm, client.firm
    assert_raise(ActiveSupport::FrozenObjectError) { client.name = "something else" }
  end

  def test_destroy_new_record
    client = Client.new
    client.destroy
    assert client.frozen?
  end

  def test_destroy_record_with_associations
    client = Client.find(3)
    client.destroy
    assert client.frozen?
    assert_kind_of Firm, client.firm
    assert_raise(ActiveSupport::FrozenObjectError) { client.name = "something else" }
  end

  def test_update_attribute
    assert !Topic.find(1).approved?
    Topic.find(1).update_attribute("approved", true)
    assert Topic.find(1).approved?

    Topic.find(1).update_attribute(:approved, false)
    assert !Topic.find(1).approved?
  end

  def test_update_attribute_for_readonly_attribute
    minivan = Minivan.find('m1')
    assert_raises(ActiveRecord::ActiveRecordError) { minivan.update_attribute(:color, 'black') }
  end

  def test_update_attribute_with_one_changed_and_one_updated
    t = Topic.order('id').limit(1).first
    title, author_name = t.title, t.author_name
    t.author_name = 'John'
    t.update_attribute(:title, 'super_title')
    assert_equal 'John', t.author_name
    assert_equal 'super_title', t.title
    assert t.changed?, "topic should have changed"
    assert t.author_name_changed?, "author_name should have changed"
    assert !t.title_changed?, "title should not have changed"
    assert_nil t.title_change, 'title change should be nil'
    assert_equal ['author_name'], t.changed

    t.reload
    assert_equal 'David', t.author_name
    assert_equal 'super_title', t.title
  end

  def test_update_attribute_with_one_updated
    t = Topic.first
    title = t.title
    t.update_attribute(:title, 'super_title')
    assert_equal 'super_title', t.title
    assert !t.changed?, "topic should not have changed"
    assert !t.title_changed?, "title should not have changed"
    assert_nil t.title_change, 'title change should be nil'

    t.reload
    assert_equal 'super_title', t.title
  end

  def test_update_attribute_for_udpated_at_on
    developer = Developer.find(1)
    prev_month = Time.now.prev_month
    developer.update_attribute(:updated_at, prev_month)
    assert_equal prev_month, developer.updated_at
    developer.update_attribute(:salary, 80001)
    assert_not_equal prev_month, developer.updated_at
    developer.reload
    assert_not_equal prev_month, developer.updated_at
  end

  def test_update_attributes
    topic = Topic.find(1)
    assert !topic.approved?
    assert_equal "The First Topic", topic.title

    topic.update_attributes("approved" => true, "title" => "The First Topic Updated")
    topic.reload
    assert topic.approved?
    assert_equal "The First Topic Updated", topic.title

    topic.update_attributes(:approved => false, :title => "The First Topic")
    topic.reload
    assert !topic.approved?
    assert_equal "The First Topic", topic.title
  end

  def test_update_attributes!
    Reply.validates_presence_of(:title)
    reply = Reply.find(2)
    assert_equal "The Second Topic of the day", reply.title
    assert_equal "Have a nice day", reply.content

    reply.update_attributes!("title" => "The Second Topic of the day updated", "content" => "Have a nice evening")
    reply.reload
    assert_equal "The Second Topic of the day updated", reply.title
    assert_equal "Have a nice evening", reply.content

    reply.update_attributes!(:title => "The Second Topic of the day", :content => "Have a nice day")
    reply.reload
    assert_equal "The Second Topic of the day", reply.title
    assert_equal "Have a nice day", reply.content

    assert_raise(ActiveRecord::RecordInvalid) { reply.update_attributes!(:title => nil, :content => "Have a nice evening") }
  ensure
    Reply.reset_callbacks(:validate)
  end

  def test_destroyed_returns_boolean
    developer = Developer.first
    assert_equal false, developer.destroyed?
    developer.destroy
    assert_equal true, developer.destroyed?

    developer = Developer.last
    assert_equal false, developer.destroyed?
    developer.delete
    assert_equal true, developer.destroyed?
  end

  def test_persisted_returns_boolean
    developer = Developer.new(:name => "Jose")
    assert_equal false, developer.persisted?
    developer.save!
    assert_equal true, developer.persisted?

    developer = Developer.first
    assert_equal true, developer.persisted?
    developer.destroy
    assert_equal false, developer.persisted?

    developer = Developer.last
    assert_equal true, developer.persisted?
    developer.delete
    assert_equal false, developer.persisted?
  end

  def test_class_level_destroy
    should_be_destroyed_reply = Reply.create("title" => "hello", "content" => "world")
    Topic.find(1).replies << should_be_destroyed_reply

    Topic.destroy(1)
    assert_raise(ActiveRecord::RecordNotFound) { Topic.find(1) }
    assert_raise(ActiveRecord::RecordNotFound) { Reply.find(should_be_destroyed_reply.id) }
  end

  def test_class_level_delete
    should_be_destroyed_reply = Reply.create("title" => "hello", "content" => "world")
    Topic.find(1).replies << should_be_destroyed_reply

    Topic.delete(1)
    assert_raise(ActiveRecord::RecordNotFound) { Topic.find(1) }
    assert_nothing_raised { Reply.find(should_be_destroyed_reply.id) }
  end

  def test_create_with_custom_timestamps
    custom_datetime = 1.hour.ago.beginning_of_day

    %w(created_at created_on updated_at updated_on).each do |attribute|
      parrot = LiveParrot.create(:name => "colombian", attribute => custom_datetime)
      assert_equal custom_datetime, parrot[attribute]
    end
  end

end
