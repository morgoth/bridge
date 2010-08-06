# encoding: utf-8
require 'cases/helper'

require 'models/topic'
require 'models/person'

class LengthValidationTest < ActiveModel::TestCase

  def teardown
    Topic.reset_callbacks(:validate)
  end

  def test_validates_length_of_with_allow_nil
    Topic.validates_length_of( :title, :is => 5, :allow_nil=>true )

    assert Topic.new("title" => "ab").invalid?
    assert Topic.new("title" => "").invalid?
    assert Topic.new("title" => nil).valid?
    assert Topic.new("title" => "abcde").valid?
  end

  def test_validates_length_of_with_allow_blank
    Topic.validates_length_of( :title, :is => 5, :allow_blank=>true )

    assert Topic.new("title" => "ab").invalid?
    assert Topic.new("title" => "").valid?
    assert Topic.new("title" => nil).valid?
    assert Topic.new("title" => "abcde").valid?
  end

  def test_validates_length_of_using_minimum
    Topic.validates_length_of :title, :minimum => 5

    t = Topic.new("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "not"
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["is too short (minimum is 5 characters)"], t.errors[:title]

    t.title = ""
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["is too short (minimum is 5 characters)"], t.errors[:title]

    t.title = nil
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["is too short (minimum is 5 characters)"], t.errors["title"]
  end

  def test_validates_length_of_using_maximum_should_allow_nil
    Topic.validates_length_of :title, :maximum => 10
    t = Topic.new
    assert t.valid?
  end

  def test_optionally_validates_length_of_using_minimum
    Topic.validates_length_of :title, :minimum => 5, :allow_nil => true

    t = Topic.new("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = nil
    assert t.valid?
  end

  def test_validates_length_of_using_maximum
    Topic.validates_length_of :title, :maximum => 5

    t = Topic.new("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "notvalid"
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["is too long (maximum is 5 characters)"], t.errors[:title]

    t.title = ""
    assert t.valid?
  end

  def test_optionally_validates_length_of_using_maximum
    Topic.validates_length_of :title, :maximum => 5, :allow_nil => true

    t = Topic.new("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = nil
    assert t.valid?
  end

  def test_validates_length_of_using_within
    Topic.validates_length_of(:title, :content, :within => 3..5)

    t = Topic.new("title" => "a!", "content" => "I'm ooooooooh so very long")
    assert t.invalid?
    assert_equal ["is too short (minimum is 3 characters)"], t.errors[:title]
    assert_equal ["is too long (maximum is 5 characters)"], t.errors[:content]

    t.title = nil
    t.content = nil
    assert t.invalid?
    assert_equal ["is too short (minimum is 3 characters)"], t.errors[:title]
    assert_equal ["is too short (minimum is 3 characters)"], t.errors[:content]

    t.title = "abe"
    t.content  = "mad"
    assert t.valid?
  end

  def test_validates_length_of_using_within_with_exclusive_range
    Topic.validates_length_of(:title, :within => 4...10)

    t = Topic.new("title" => "9 chars!!")
    assert t.valid?

    t.title = "Now I'm 10"
    assert t.invalid?
    assert_equal ["is too long (maximum is 9 characters)"], t.errors[:title]

    t.title = "Four"
    assert t.valid?
  end

  def test_optionally_validates_length_of_using_within
    Topic.validates_length_of :title, :content, :within => 3..5, :allow_nil => true

    t = Topic.new('title' => 'abc', 'content' => 'abcd')
    assert t.valid?

    t.title = nil
    assert t.valid?
  end

  def test_validates_length_of_using_is
    Topic.validates_length_of :title, :is => 5

    t = Topic.new("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "notvalid"
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["is the wrong length (should be 5 characters)"], t.errors[:title]

    t.title = ""
    assert t.invalid?

    t.title = nil
    assert t.invalid?
  end

  def test_optionally_validates_length_of_using_is
    Topic.validates_length_of :title, :is => 5, :allow_nil => true

    t = Topic.new("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = nil
    assert t.valid?
  end

  def test_validates_length_of_using_bignum
    bigmin = 2 ** 30
    bigmax = 2 ** 32
    bigrange = bigmin...bigmax
    assert_nothing_raised do
      Topic.validates_length_of :title, :is => bigmin + 5
      Topic.validates_length_of :title, :within => bigrange
      Topic.validates_length_of :title, :in => bigrange
      Topic.validates_length_of :title, :minimum => bigmin
      Topic.validates_length_of :title, :maximum => bigmax
    end
  end

  def test_validates_length_of_nasty_params
    assert_raise(ArgumentError) { Topic.validates_length_of(:title, :is=>-6) }
    assert_raise(ArgumentError) { Topic.validates_length_of(:title, :within=>6) }
    assert_raise(ArgumentError) { Topic.validates_length_of(:title, :minimum=>"a") }
    assert_raise(ArgumentError) { Topic.validates_length_of(:title, :maximum=>"a") }
    assert_raise(ArgumentError) { Topic.validates_length_of(:title, :within=>"a") }
    assert_raise(ArgumentError) { Topic.validates_length_of(:title, :is=>"a") }
  end

  def test_validates_length_of_custom_errors_for_minimum_with_message
    Topic.validates_length_of( :title, :minimum=>5, :message=>"boo %{count}" )
    t = Topic.new("title" => "uhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["boo 5"], t.errors[:title]
  end

  def test_validates_length_of_custom_errors_for_minimum_with_too_short
    Topic.validates_length_of( :title, :minimum=>5, :too_short=>"hoo %{count}" )
    t = Topic.new("title" => "uhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["hoo 5"], t.errors[:title]
  end

  def test_validates_length_of_custom_errors_for_maximum_with_message
    Topic.validates_length_of( :title, :maximum=>5, :message=>"boo %{count}" )
    t = Topic.new("title" => "uhohuhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["boo 5"], t.errors[:title]
  end

  def test_validates_length_of_custom_errors_for_in
    Topic.validates_length_of(:title, :in => 10..20, :message => "hoo %{count}")
    t = Topic.new("title" => "uhohuhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["hoo 10"], t.errors["title"]

    t = Topic.new("title" => "uhohuhohuhohuhohuhohuhohuhohuhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["hoo 20"], t.errors["title"]
  end

  def test_validates_length_of_custom_errors_for_maximum_with_too_long
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>"hoo %{count}" )
    t = Topic.new("title" => "uhohuhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["hoo 5"], t.errors["title"]
  end

  def test_validates_length_of_custom_errors_for_both_too_short_and_too_long
    Topic.validates_length_of :title, :minimum => 3, :maximum => 5, :too_short => 'too short', :too_long => 'too long'

    t = Topic.new(:title => 'a')
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ['too short'], t.errors['title']

    t = Topic.new(:title => 'aaaaaa')
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ['too long'], t.errors['title']
  end

  def test_validates_length_of_custom_errors_for_is_with_message
    Topic.validates_length_of( :title, :is=>5, :message=>"boo %{count}" )
    t = Topic.new("title" => "uhohuhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["boo 5"], t.errors["title"]
  end

  def test_validates_length_of_custom_errors_for_is_with_wrong_length
    Topic.validates_length_of( :title, :is=>5, :wrong_length=>"hoo %{count}" )
    t = Topic.new("title" => "uhohuhoh", "content" => "whatever")
    assert t.invalid?
    assert t.errors[:title].any?
    assert_equal ["hoo 5"], t.errors["title"]
  end

  def test_validates_length_of_using_minimum_utf8
    with_kcode('UTF8') do
      Topic.validates_length_of :title, :minimum => 5

      t = Topic.new("title" => "一二三四五", "content" => "whatever")
      assert t.valid?

      t.title = "一二三四"
      assert t.invalid?
      assert t.errors[:title].any?
      assert_equal ["is too short (minimum is 5 characters)"], t.errors["title"]
    end
  end

  def test_validates_length_of_using_maximum_utf8
    with_kcode('UTF8') do
      Topic.validates_length_of :title, :maximum => 5

      t = Topic.new("title" => "一二三四五", "content" => "whatever")
      assert t.valid?

      t.title = "一二34五六"
      assert t.invalid?
      assert t.errors[:title].any?
      assert_equal ["is too long (maximum is 5 characters)"], t.errors["title"]
    end
  end

  def test_validates_length_of_using_within_utf8
    with_kcode('UTF8') do
      Topic.validates_length_of(:title, :content, :within => 3..5)

      t = Topic.new("title" => "一二", "content" => "12三四五六七")
      assert t.invalid?
      assert_equal ["is too short (minimum is 3 characters)"], t.errors[:title]
      assert_equal ["is too long (maximum is 5 characters)"], t.errors[:content]
      t.title = "一二三"
      t.content  = "12三"
      assert t.valid?
    end
  end

  def test_optionally_validates_length_of_using_within_utf8
    with_kcode('UTF8') do
      Topic.validates_length_of :title, :within => 3..5, :allow_nil => true

      t = Topic.new(:title => "一二三四五")
      assert t.valid?, t.errors.inspect

      t = Topic.new(:title => "一二三")
      assert t.valid?, t.errors.inspect

      t.title = nil
      assert t.valid?, t.errors.inspect
    end
  end

  def test_validates_length_of_using_is_utf8
    with_kcode('UTF8') do
      Topic.validates_length_of :title, :is => 5

      t = Topic.new("title" => "一二345", "content" => "whatever")
      assert t.valid?

      t.title = "一二345六"
      assert t.invalid?
      assert t.errors[:title].any?
      assert_equal ["is the wrong length (should be 5 characters)"], t.errors["title"]
    end
  end

  def test_validates_length_of_with_block
    Topic.validates_length_of :content, :minimum => 5, :too_short=>"Your essay must be at least %{count} words.",
                                        :tokenizer => lambda {|str| str.scan(/\w+/) }
    t = Topic.new(:content => "this content should be long enough")
    assert t.valid?

    t.content = "not long enough"
    assert t.invalid?
    assert t.errors[:content].any?
    assert_equal ["Your essay must be at least 5 words."], t.errors[:content]
  end

  def test_validates_length_of_for_ruby_class
    Person.validates_length_of :karma, :minimum => 5

    p = Person.new
    p.karma = "Pix"
    assert p.invalid?

    assert_equal ["is too short (minimum is 5 characters)"], p.errors[:karma]

    p.karma = "The Smiths"
    assert p.valid?
  ensure
    Person.reset_callbacks(:validate)
  end
end
