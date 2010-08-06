require "cases/helper"
require 'models/post'
require 'models/comment'
require 'models/author'
require 'models/categorization'
require 'models/company'
require 'models/topic'
require 'models/reply'
require 'models/person'

class CascadedEagerLoadingTest < ActiveRecord::TestCase
  fixtures :authors, :mixins, :companies, :posts, :topics, :accounts, :comments, :categorizations, :people

  def test_eager_association_loading_with_cascaded_two_levels
    authors = Author.find(:all, :include=>{:posts=>:comments}, :order=>"authors.id")
    assert_equal 2, authors.size
    assert_equal 5, authors[0].posts.size
    assert_equal 1, authors[1].posts.size
    assert_equal 9, authors[0].posts.collect{|post| post.comments.size }.inject(0){|sum,i| sum+i}
  end

  def test_eager_association_loading_with_cascaded_two_levels_and_one_level
    authors = Author.find(:all, :include=>[{:posts=>:comments}, :categorizations], :order=>"authors.id")
    assert_equal 2, authors.size
    assert_equal 5, authors[0].posts.size
    assert_equal 1, authors[1].posts.size
    assert_equal 9, authors[0].posts.collect{|post| post.comments.size }.inject(0){|sum,i| sum+i}
    assert_equal 1, authors[0].categorizations.size
    assert_equal 2, authors[1].categorizations.size
  end

  def test_eager_association_loading_with_hmt_does_not_table_name_collide_when_joining_associations
    assert_nothing_raised do
      Author.joins(:posts).eager_load(:comments).where(:posts => {:taggings_count => 1}).all
    end
    authors = Author.joins(:posts).eager_load(:comments).where(:posts => {:taggings_count => 1}).all
    assert_equal 1, assert_no_queries { authors.size }
    assert_equal 9, assert_no_queries { authors[0].comments.size }
  end

  def test_eager_association_loading_grafts_stashed_associations_to_correct_parent
    assert_nothing_raised do
      Person.eager_load(:primary_contact => :primary_contact).where('primary_contacts_people_2.first_name = ?', 'Susan').order('people.id').all
    end
    assert_equal people(:michael), Person.eager_load(:primary_contact => :primary_contact).where('primary_contacts_people_2.first_name = ?', 'Susan').order('people.id').first
  end

  def test_eager_association_loading_with_join_for_count
    authors = Author.joins(:special_posts).includes([:posts, :categorizations])

    assert_nothing_raised { authors.count }
    assert_queries(3) { authors.all }
  end

  def test_eager_association_loading_with_cascaded_two_levels_with_two_has_many_associations
    authors = Author.find(:all, :include=>{:posts=>[:comments, :categorizations]}, :order=>"authors.id")
    assert_equal 2, authors.size
    assert_equal 5, authors[0].posts.size
    assert_equal 1, authors[1].posts.size
    assert_equal 9, authors[0].posts.collect{|post| post.comments.size }.inject(0){|sum,i| sum+i}
  end

  def test_eager_association_loading_with_cascaded_two_levels_and_self_table_reference
    authors = Author.find(:all, :include=>{:posts=>[:comments, :author]}, :order=>"authors.id")
    assert_equal 2, authors.size
    assert_equal 5, authors[0].posts.size
    assert_equal authors(:david).name, authors[0].name
    assert_equal [authors(:david).name], authors[0].posts.collect{|post| post.author.name}.uniq
  end

  def test_eager_association_loading_with_cascaded_two_levels_with_condition
    authors = Author.find(:all, :include=>{:posts=>:comments}, :conditions=>"authors.id=1", :order=>"authors.id")
    assert_equal 1, authors.size
    assert_equal 5, authors[0].posts.size
  end

  def test_eager_association_loading_with_cascaded_three_levels_by_ping_pong
    firms = Firm.find(:all, :include=>{:account=>{:firm=>:account}}, :order=>"companies.id")
    assert_equal 2, firms.size
    assert_equal firms.first.account, firms.first.account.firm.account
    assert_equal companies(:first_firm).account, assert_no_queries { firms.first.account.firm.account }
    assert_equal companies(:first_firm).account.firm.account, assert_no_queries { firms.first.account.firm.account }
  end

  def test_eager_association_loading_with_has_many_sti
    topics = Topic.find(:all, :include => :replies, :order => 'topics.id')
    first, second, = topics(:first).replies.size, topics(:second).replies.size
    assert_no_queries do
      assert_equal first, topics[0].replies.size
      assert_equal second, topics[1].replies.size
    end
  end

  def test_eager_association_loading_with_has_many_sti_and_subclasses
    silly = SillyReply.new(:title => "gaga", :content => "boo-boo", :parent_id => 1)
    silly.parent_id = 1
    assert silly.save

    topics = Topic.find(:all, :include => :replies, :order => 'topics.id, replies_topics.id')
    assert_no_queries do
      assert_equal 2, topics[0].replies.size
      assert_equal 0, topics[1].replies.size
    end
  end

  def test_eager_association_loading_with_belongs_to_sti
    replies = Reply.find(:all, :include => :topic, :order => 'topics.id')
    assert replies.include?(topics(:second))
    assert !replies.include?(topics(:first))
    assert_equal topics(:first), assert_no_queries { replies.first.topic }
  end

  def test_eager_association_loading_with_multiple_stis_and_order
    author = Author.find(:first, :include => { :posts => [ :special_comments , :very_special_comment ] }, :order => 'authors.name, comments.body, very_special_comments_posts.body', :conditions => 'posts.id = 4')
    assert_equal authors(:david), author
    assert_no_queries do
      author.posts.first.special_comments
      author.posts.first.very_special_comment
    end
  end

  def test_eager_association_loading_of_stis_with_multiple_references
    authors = Author.find(:all, :include => { :posts => { :special_comments => { :post => [ :special_comments, :very_special_comment ] } } }, :order => 'comments.body, very_special_comments_posts.body', :conditions => 'posts.id = 4')
    assert_equal [authors(:david)], authors
    assert_no_queries do
      authors.first.posts.first.special_comments.first.post.special_comments
      authors.first.posts.first.special_comments.first.post.very_special_comment
    end
  end

  def test_eager_association_loading_where_first_level_returns_nil
    authors = Author.find(:all, :include => {:post_about_thinking => :comments}, :order => 'authors.id DESC')
    assert_equal [authors(:mary), authors(:david)], authors
    assert_no_queries do
      authors[1].post_about_thinking.comments.first
    end
  end
end

require 'models/vertex'
require 'models/edge'
class CascadedEagerLoadingTest < ActiveRecord::TestCase
  fixtures :edges, :vertices

  def test_eager_association_loading_with_recursive_cascading_four_levels_has_many_through
    source = Vertex.find(:first, :include=>{:sinks=>{:sinks=>{:sinks=>:sinks}}}, :order => 'vertices.id')
    assert_equal vertices(:vertex_4), assert_no_queries { source.sinks.first.sinks.first.sinks.first }
  end

  def test_eager_association_loading_with_recursive_cascading_four_levels_has_and_belongs_to_many
    sink = Vertex.find(:first, :include=>{:sources=>{:sources=>{:sources=>:sources}}}, :order => 'vertices.id DESC')
    assert_equal vertices(:vertex_1), assert_no_queries { sink.sources.first.sources.first.sources.first.sources.first }
  end
end
