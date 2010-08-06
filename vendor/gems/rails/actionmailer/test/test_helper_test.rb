require 'abstract_unit'

class TestHelperMailer < ActionMailer::Base
  def test
    recipients "test@example.com"
    from       "tester@example.com"

    @world = "Earth"
    render(:inline => "Hello, <%= @world %>")
  end
end

class TestHelperMailerTest < ActionMailer::TestCase
  def test_setup_sets_right_action_mailer_options
    assert_equal :test, ActionMailer::Base.delivery_method
    assert ActionMailer::Base.perform_deliveries
    assert_equal [], ActionMailer::Base.deliveries
  end

  def test_setup_creates_the_expected_mailer
    assert_kind_of Mail::Message, @expected
    assert_equal "1.0", @expected.mime_version
    assert_equal "text/plain", @expected.mime_type
  end

  def test_mailer_class_is_correctly_inferred
    assert_equal TestHelperMailer, self.class.mailer_class
  end

  def test_determine_default_mailer_raises_correct_error
    assert_raise(ActionMailer::NonInferrableMailerError) do
      self.class.determine_default_mailer("NotAMailerTest")
    end
  end
  
  def test_charset_is_utf_8
    assert_equal "UTF-8", charset
  end

  def test_assert_emails
    assert_nothing_raised do
      assert_emails 1 do
        TestHelperMailer.test.deliver
      end
    end
  end
  
  def test_repeated_assert_emails_calls
    assert_nothing_raised do
      assert_emails 1 do
        TestHelperMailer.test.deliver
      end
    end
    
    assert_nothing_raised do
      assert_emails 2 do
        TestHelperMailer.test.deliver
        TestHelperMailer.test.deliver
      end
    end
  end
  
  def test_assert_emails_with_no_block
    assert_nothing_raised do
      TestHelperMailer.test.deliver
      assert_emails 1
    end
    
    assert_nothing_raised do
      TestHelperMailer.test.deliver
      TestHelperMailer.test.deliver
      assert_emails 3
    end
  end
  
  def test_assert_no_emails
    assert_nothing_raised do
      assert_no_emails do
        TestHelperMailer.test
      end
    end
  end
  
  def test_assert_emails_too_few_sent
    error = assert_raise ActiveSupport::TestCase::Assertion do
      assert_emails 2 do
        TestHelperMailer.test.deliver
      end
    end
    
    assert_match(/2 .* but 1/, error.message)
  end
  
  def test_assert_emails_too_many_sent
    error = assert_raise ActiveSupport::TestCase::Assertion do
      assert_emails 1 do
        TestHelperMailer.test.deliver
        TestHelperMailer.test.deliver
      end
    end
    
    assert_match(/1 .* but 2/, error.message)
  end
  
  def test_assert_no_emails_failure
    error = assert_raise ActiveSupport::TestCase::Assertion do
      assert_no_emails do
        TestHelperMailer.test.deliver
      end
    end
    
    assert_match(/0 .* but 1/, error.message)
  end
end

class AnotherTestHelperMailerTest < ActionMailer::TestCase
  tests TestHelperMailer

  def setup
    @test_var = "a value"
  end

  def test_setup_shouldnt_conflict_with_mailer_setup
    assert_kind_of Mail::Message, @expected
    assert_equal 'a value', @test_var
  end
end
