require "cases/helper"
require 'models/tagging'
require 'models/post'
require 'models/topic'
require 'models/comment'
require 'models/reply'
require 'models/author'
require 'models/comment'
require 'models/entrant'
require 'models/developer'
require 'models/company'
require 'models/bird'

class RelationTest < ActiveRecord::TestCase
  fixtures :authors, :topics, :entrants, :developers, :companies, :developers_projects, :accounts, :categories, :categorizations, :posts, :comments,
    :taggings

  def test_apply_relation_as_where_id
    posts = Post.arel_table
    post_authors = posts.where(posts[:author_id].eq(1)).project(posts[:id])
    assert_equal 5, post_authors.to_a.size
    assert_equal 5, Post.where(:id => post_authors).size
  end

  def test_multivalue_where
    posts = Post.where('author_id = ? AND id = ?', 1, 1)
    assert_equal 1, posts.to_a.size
  end

  def test_scoped
    topics = Topic.scoped
    assert_kind_of ActiveRecord::Relation, topics
    assert_equal 4, topics.size
  end

  def test_to_json
    assert_nothing_raised  { Bird.scoped.to_json }
    assert_nothing_raised  { Bird.scoped.all.to_json }
  end

  def test_to_yaml
    assert_nothing_raised  { Bird.scoped.to_yaml }
    assert_nothing_raised  { Bird.scoped.all.to_yaml }
  end

  def test_to_xml
    assert_nothing_raised  { Bird.scoped.to_xml }
    assert_nothing_raised  { Bird.scoped.all.to_xml }
  end

  def test_scoped_all
    topics = Topic.scoped.all
    assert_kind_of Array, topics
    assert_no_queries { assert_equal 4, topics.size }
  end

  def test_loaded_all
    topics = Topic.scoped

    assert_queries(1) do
      2.times { assert_equal 4, topics.all.size }
    end

    assert topics.loaded?
  end

  def test_scoped_first
    topics = Topic.scoped.order('id ASC')

    assert_queries(1) do
      2.times { assert_equal "The First Topic", topics.first.title }
    end

    assert ! topics.loaded?
  end

  def test_loaded_first
    topics = Topic.scoped.order('id ASC')

    assert_queries(1) do
      topics.all # force load
      2.times { assert_equal "The First Topic", topics.first.title }
    end

    assert topics.loaded?
  end

  def test_reload
    topics = Topic.scoped

    assert_queries(1) do
      2.times { topics.to_a }
    end

    assert topics.loaded?

    original_size = topics.to_a.size
    Topic.create! :title => 'fake'

    assert_queries(1) { topics.reload }
    assert_equal original_size + 1, topics.size
    assert topics.loaded?
  end

  def test_finding_with_conditions
    assert_equal ["David"], Author.where(:name => 'David').map(&:name)
    assert_equal ['Mary'],  Author.where(["name = ?", 'Mary']).map(&:name)
    assert_equal ['Mary'],  Author.where("name = ?", 'Mary').map(&:name)
  end

  def test_finding_with_order
    topics = Topic.order('id')
    assert_equal 4, topics.to_a.size
    assert_equal topics(:first).title, topics.first.title
  end

  def test_finding_with_order_concatenated
    topics = Topic.order('author_name').order('title')
    assert_equal 4, topics.to_a.size
    assert_equal topics(:fourth).title, topics.first.title
  end

  def test_finding_with_reorder
    topics = Topic.order('author_name').order('title').reorder('id')
    assert_equal 4, topics.to_a.size
    assert_equal topics(:first).title, topics.first.title
  end

  def test_finding_with_order_and_take
    entrants = Entrant.order("id ASC").limit(2).to_a

    assert_equal 2, entrants.size
    assert_equal entrants(:first).name, entrants.first.name
  end

  def test_finding_with_order_limit_and_offset
    entrants = Entrant.order("id ASC").limit(2).offset(1)

    assert_equal 2, entrants.to_a.size
    assert_equal entrants(:second).name, entrants.first.name

    entrants = Entrant.order("id ASC").limit(2).offset(2)
    assert_equal 1, entrants.to_a.size
    assert_equal entrants(:third).name, entrants.first.name
  end

  def test_finding_with_group
    developers = Developer.group("salary").select("salary").to_a
    assert_equal 4, developers.size
    assert_equal 4, developers.map(&:salary).uniq.size
  end

  def test_select_with_block
    even_ids = Developer.scoped.select {|d| d.id % 2 == 0 }.map(&:id)
    assert_equal [2, 4, 6, 8, 10], even_ids.sort
  end

  def test_finding_with_hash_conditions_on_joined_table
    firms = DependentFirm.joins(:account).where({:name => 'RailsCore', :accounts => { :credit_limit => 55..60 }}).to_a
    assert_equal 1, firms.size
    assert_equal companies(:rails_core), firms.first
  end

  def test_find_all_with_join
    developers_on_project_one = Developer.joins('LEFT JOIN developers_projects ON developers.id = developers_projects.developer_id').
      where('project_id=1').to_a

    assert_equal 3, developers_on_project_one.length
    developer_names = developers_on_project_one.map { |d| d.name }
    assert developer_names.include?('David')
    assert developer_names.include?('Jamis')
  end

  def test_find_on_hash_conditions
    assert_equal Topic.find(:all, :conditions => {:approved => false}), Topic.where({ :approved => false }).to_a
  end

  def test_joins_with_string_array
    person_with_reader_and_post = Post.joins([
        "INNER JOIN categorizations ON categorizations.post_id = posts.id",
        "INNER JOIN categories ON categories.id = categorizations.category_id AND categories.type = 'SpecialCategory'"
      ]
    ).to_a
    assert_equal 1, person_with_reader_and_post.size
  end

  def test_scoped_responds_to_delegated_methods
    relation = Topic.scoped

    ["map", "uniq", "sort", "insert", "delete", "update"].each do |method|
      assert_respond_to relation, method, "Topic.scoped should respond to #{method.inspect}"
    end
  end

  def test_respond_to_private_arel_methods
    relation = Topic.scoped

    assert ! relation.respond_to?(:matching_attributes)
    assert relation.respond_to?(:matching_attributes, true)
  end

  def test_respond_to_dynamic_finders
    relation = Topic.scoped

    ["find_by_title", "find_by_title_and_author_name", "find_or_create_by_title", "find_or_initialize_by_title_and_author_name"].each do |method|
      assert_respond_to relation, method, "Topic.scoped should respond to #{method.inspect}"
    end
  end

  def test_respond_to_class_methods_and_named_scopes
    assert DeveloperOrderedBySalary.scoped.respond_to?(:all_ordered_by_name)
    assert Topic.scoped.respond_to?(:by_lifo)
  end

  def test_find_with_readonly_option
    Developer.scoped.each { |d| assert !d.readonly? }
    Developer.scoped.readonly.each { |d| assert d.readonly? }
  end

  def test_eager_association_loading_of_stis_with_multiple_references
    authors = Author.eager_load(:posts => { :special_comments => { :post => [ :special_comments, :very_special_comment ] } }).
      order('comments.body, very_special_comments_posts.body').where('posts.id = 4').to_a

    assert_equal [authors(:david)], authors
    assert_no_queries do
      authors.first.posts.first.special_comments.first.post.special_comments
      authors.first.posts.first.special_comments.first.post.very_special_comment
    end
  end

  def test_find_with_preloaded_associations
    assert_queries(2) do
      posts = Post.preload(:comments)
      assert posts.first.comments.first
    end

    assert_queries(2) do
      posts = Post.preload(:comments).to_a
      assert posts.first.comments.first
    end

    assert_queries(2) do
      posts = Post.preload(:author)
      assert posts.first.author
    end

    assert_queries(2) do
      posts = Post.preload(:author).to_a
      assert posts.first.author
    end

    assert_queries(3) do
      posts = Post.preload(:author, :comments).to_a
      assert posts.first.author
      assert posts.first.comments.first
    end
  end

  def test_find_with_included_associations
    assert_queries(2) do
      posts = Post.includes(:comments)
      assert posts.first.comments.first
    end

    assert_queries(2) do
      posts = Post.scoped.includes(:comments)
      assert posts.first.comments.first
    end

    assert_queries(2) do
      posts = Post.includes(:author)
      assert posts.first.author
    end

    assert_queries(3) do
      posts = Post.includes(:author, :comments).to_a
      assert posts.first.author
      assert posts.first.comments.first
    end
  end

  def test_default_scope_with_conditions_string
    assert_equal Developer.find_all_by_name('David').map(&:id).sort, DeveloperCalledDavid.scoped.map(&:id).sort
    assert_nil DeveloperCalledDavid.create!.name
  end

  def test_default_scope_with_conditions_hash
    assert_equal Developer.find_all_by_name('Jamis').map(&:id).sort, DeveloperCalledJamis.scoped.map(&:id).sort
    assert_equal 'Jamis', DeveloperCalledJamis.create!.name
  end

  def test_default_scoping_finder_methods
    developers = DeveloperCalledDavid.order('id').map(&:id).sort
    assert_equal Developer.find_all_by_name('David').map(&:id).sort, developers
  end

  def test_loading_with_one_association
    posts = Post.preload(:comments)
    post = posts.find { |p| p.id == 1 }
    assert_equal 2, post.comments.size
    assert post.comments.include?(comments(:greetings))

    post = Post.where("posts.title = 'Welcome to the weblog'").preload(:comments).first
    assert_equal 2, post.comments.size
    assert post.comments.include?(comments(:greetings))

    posts = Post.preload(:last_comment)
    post = posts.find { |p| p.id == 1 }
    assert_equal Post.find(1).last_comment, post.last_comment
  end

  def test_loading_with_one_association_with_non_preload
    posts = Post.eager_load(:last_comment).order('comments.id DESC')
    post = posts.find { |p| p.id == 1 }
    assert_equal Post.find(1).last_comment, post.last_comment
  end

  def test_dynamic_find_by_attributes
    david = authors(:david)
    author = Author.preload(:taggings).find_by_id(david.id)
    expected_taggings = taggings(:welcome_general, :thinking_general)

    assert_no_queries do
      assert_equal expected_taggings, author.taggings.uniq.sort_by { |t| t.id }
    end

    authors = Author.scoped
    assert_equal david, authors.find_by_id_and_name(david.id, david.name)
    assert_equal david, authors.find_by_id_and_name!(david.id, david.name)
  end

  def test_dynamic_find_by_attributes_bang
    author = Author.scoped.find_by_id!(authors(:david).id)
    assert_equal "David", author.name

    assert_raises(ActiveRecord::RecordNotFound) { Author.scoped.find_by_id_and_name!(20, 'invalid') }
  end

  def test_dynamic_find_all_by_attributes
    authors = Author.scoped

    davids = authors.find_all_by_name('David')
    assert_kind_of Array, davids
    assert_equal [authors(:david)], davids
  end

  def test_dynamic_find_or_initialize_by_attributes
    authors = Author.scoped

    lifo = authors.find_or_initialize_by_name('Lifo')
    assert_equal "Lifo", lifo.name
    assert lifo.new_record?

    assert_equal authors(:david), authors.find_or_initialize_by_name(:name => 'David')
  end

  def test_dynamic_find_or_create_by_attributes
    authors = Author.scoped

    lifo = authors.find_or_create_by_name('Lifo')
    assert_equal "Lifo", lifo.name
    assert ! lifo.new_record?

    assert_equal authors(:david), authors.find_or_create_by_name(:name => 'David')
  end

  def test_find_id
    authors = Author.scoped

    david = authors.find(authors(:david).id)
    assert_equal 'David', david.name

    assert_raises(ActiveRecord::RecordNotFound) { authors.where(:name => 'lifo').find('42') }
  end

  def test_find_ids
    authors = Author.order('id ASC')

    results = authors.find(authors(:david).id, authors(:mary).id)
    assert_kind_of Array, results
    assert_equal 2, results.size
    assert_equal 'David', results[0].name
    assert_equal 'Mary', results[1].name
    assert_equal results, authors.find([authors(:david).id, authors(:mary).id])

    assert_raises(ActiveRecord::RecordNotFound) { authors.where(:name => 'lifo').find(authors(:david).id, '42') }
    assert_raises(ActiveRecord::RecordNotFound) { authors.find(['42', 43]) }
  end

  def test_find_in_empty_array
    authors = Author.scoped.where(:id => [])
    assert authors.all.blank?
  end

  def test_exists
    davids = Author.where(:name => 'David')
    assert davids.exists?
    assert davids.exists?(authors(:david).id)
    assert ! davids.exists?(authors(:mary).id)
    assert ! davids.exists?("42")
    assert ! davids.exists?(42)

    fake  = Author.where(:name => 'fake author')
    assert ! fake.exists?
    assert ! fake.exists?(authors(:david).id)
  end

  def test_last
    authors = Author.scoped
    assert_equal authors(:mary), authors.last
  end

  def test_destroy_all
    davids = Author.where(:name => 'David')

    # Force load
    assert_equal [authors(:david)], davids.to_a
    assert davids.loaded?

    assert_difference('Author.count', -1) { davids.destroy_all }

    assert_equal [], davids.to_a
    assert davids.loaded?
  end

  def test_delete_all
    davids = Author.where(:name => 'David')

    assert_difference('Author.count', -1) { davids.delete_all }
    assert ! davids.loaded?
  end

  def test_delete_all_loaded
    davids = Author.where(:name => 'David')

    # Force load
    assert_equal [authors(:david)], davids.to_a
    assert davids.loaded?

    assert_difference('Author.count', -1) { davids.delete_all }

    assert_equal [], davids.to_a
    assert davids.loaded?
  end

  def test_relation_merging
    devs = Developer.where("salary >= 80000") & Developer.limit(2) & Developer.order('id ASC').where("id < 3")
    assert_equal [developers(:david), developers(:jamis)], devs.to_a

    dev_with_count = Developer.limit(1) & Developer.order('id DESC') & Developer.select('developers.*')
    assert_equal [developers(:poor_jamis)], dev_with_count.to_a
  end

  def test_relation_merging_with_eager_load
    relations = []
    relations << (Post.order('comments.id DESC') & Post.eager_load(:last_comment) & Post.scoped)
    relations << (Post.eager_load(:last_comment) & Post.order('comments.id DESC') & Post.scoped)

    relations.each do |posts|
      post = posts.find { |p| p.id == 1 }
      assert_equal Post.find(1).last_comment, post.last_comment
    end
  end

  def test_relation_merging_with_locks
    devs = Developer.lock.where("salary >= 80000").order("id DESC") & Developer.limit(2)
    assert devs.locked.present?
  end

  def test_relation_merging_with_preload
    [Post.scoped & Post.preload(:author), Post.preload(:author) & Post.scoped].each do |posts|
      assert_queries(2) { assert posts.first.author }
    end
  end

  def test_count
    posts = Post.scoped

    assert_equal 7, posts.count
    assert_equal 7, posts.count(:all)
    assert_equal 7, posts.count(:id)

    assert_equal 1, posts.where('comments_count > 1').count
    assert_equal 5, posts.where(:comments_count => 0).count
  end

  def test_count_with_distinct
    posts = Post.scoped

    assert_equal 3, posts.count(:comments_count, :distinct => true)
    assert_equal 7, posts.count(:comments_count, :distinct => false)

    assert_equal 3, posts.select(:comments_count).count(:distinct => true)
    assert_equal 7, posts.select(:comments_count).count(:distinct => false)
  end

  def test_count_explicit_columns
    Post.update_all(:comments_count => nil)
    posts = Post.scoped

    assert_equal [0], posts.select('comments_count').where('id is not null').group('id').order('id').count.values.uniq
    assert_equal 7, posts.where('id is not null').select('comments_count').count

    assert_equal 7, posts.select('comments_count').count('id')
    assert_equal 0, posts.select('comments_count').count
    assert_equal 0, posts.count(:comments_count)
    assert_equal 0, posts.count('comments_count')
  end

  def test_multiple_selects
    post = Post.scoped.select('comments_count').select('title').order("id ASC").first
    assert_equal "Welcome to the weblog", post.title
    assert_equal 2, post.comments_count
  end

  def test_size
    posts = Post.scoped

    assert_queries(1) { assert_equal 7, posts.size }
    assert ! posts.loaded?

    best_posts = posts.where(:comments_count => 0)
    best_posts.to_a # force load
    assert_no_queries { assert_equal 5, best_posts.size }
  end

  def test_count_complex_chained_relations
    posts = Post.select('comments_count').where('id is not null').group("author_id").where("comments_count > 0")

    expected = { 1 => 2 }
    assert_equal expected, posts.count
  end

  def test_any
    posts = Post.scoped

    assert_queries(3) do
      assert posts.any? # Uses COUNT()
      assert ! posts.where(:id => nil).any?

      assert posts.any? {|p| p.id > 0 }
      assert ! posts.any? {|p| p.id <= 0 }
    end

    assert posts.loaded?
  end

  def test_many
    posts = Post.scoped

    assert_queries(2) do
      assert posts.many? # Uses COUNT()
      assert posts.many? {|p| p.id > 0 }
      assert ! posts.many? {|p| p.id < 2 }
    end

    assert posts.loaded?
  end

  def test_many_with_limits
    posts = Post.scoped

    assert posts.many?
    assert ! posts.limit(1).many?
  end

  def test_build
    posts = Post.scoped

    post = posts.new
    assert_kind_of Post, post
  end

  def test_scoped_build
    posts = Post.where(:title => 'You told a lie')

    post = posts.new
    assert_kind_of Post, post
    assert_equal 'You told a lie', post.title
  end

  def test_create
    birds = Bird.scoped

    sparrow = birds.create
    assert_kind_of Bird, sparrow
    assert sparrow.new_record?

    hen = birds.where(:name => 'hen').create
    assert ! hen.new_record?
    assert_equal 'hen', hen.name
  end

  def test_create_bang
    birds = Bird.scoped

    assert_raises(ActiveRecord::RecordInvalid) { birds.create! }

    hen = birds.where(:name => 'hen').create!
    assert_kind_of Bird, hen
    assert ! hen.new_record?
    assert_equal 'hen', hen.name
  end

  def test_explicit_create_scope
    hens = Bird.where(:name => 'hen')
    assert_equal 'hen', hens.new.name

    hens = hens.create_with(:name => 'cock')
    assert_equal 'cock', hens.new.name
  end

  def test_except
    relation = Post.where(:author_id => 1).order('id ASC').limit(1)
    assert_equal [posts(:welcome)], relation.all

    author_posts = relation.except(:order, :limit)
    assert_equal Post.where(:author_id => 1).all, author_posts.all

    all_posts = relation.except(:where, :order, :limit)
    assert_equal Post.all, all_posts.all
  end

  def test_anonymous_extension
    relation = Post.where(:author_id => 1).order('id ASC').extending do
      def author
        'lifo'
      end
    end

    assert_equal "lifo", relation.author
    assert_equal "lifo", relation.limit(1).author
  end

  def test_named_extension
    relation = Post.where(:author_id => 1).order('id ASC').extending(Post::NamedExtension)
    assert_equal "lifo", relation.author
    assert_equal "lifo", relation.limit(1).author
  end

  def test_order_by_relation_attribute
    assert_equal Post.order(Post.arel_table[:title]).all, Post.order("title").all
  end

  def test_relations_limit_with_conditions_or_limit
    assert_equal Post.limit(2).size, Post.limit(2).all.size
  end
end
