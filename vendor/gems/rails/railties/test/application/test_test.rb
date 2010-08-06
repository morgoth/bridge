require 'isolation/abstract_unit'

module ApplicationTests
  class TestTest < Test::Unit::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      build_app
      boot_rails
    end

    test "truth" do
      app_file 'test/unit/foo_test.rb', <<-RUBY
        require 'test_helper'

        class FooTest < ActiveSupport::TestCase
          def test_truth
            assert true
          end
        end
      RUBY

      run_test 'unit/foo_test.rb'
    end

    # Run just in Ruby < 1.9
    if defined?(Test::Unit::Util::BacktraceFilter)
      test "adds backtrace cleaner" do
        app_file 'test/unit/backtrace_test.rb', <<-RUBY
          require 'test_helper'

          class FooTest < ActiveSupport::TestCase
            def test_truth
              assert Test::Unit::Util::BacktraceFilter.ancestors.include?(Rails::BacktraceFilterForTestUnit)
            end
          end
        RUBY

        run_test 'unit/backtrace_test.rb'
      end
    end

    test "integration test" do
      controller 'posts', <<-RUBY
        class PostsController < ActionController::Base
        end
      RUBY

      app_file 'app/views/posts/index.html.erb', <<-HTML
        Posts#index
      HTML

      app_file 'test/integration/posts_test.rb', <<-RUBY
        require 'test_helper'

        class PostsTest < ActionController::IntegrationTest
          def test_index
            get '/posts'
            assert_response :success
            assert_template "index"
          end
        end
      RUBY

      run_test 'integration/posts_test.rb'
    end

    private
      def run_test(name)
        result = ruby '-Itest', "#{app_path}/test/#{name}"
        assert_equal 0, $?.to_i, result
      end

      def ruby(*args)
        Dir.chdir(app_path) do
          `RUBYLIB='#{$:.join(':')}' #{Gem.ruby} #{args.join(' ')}`
        end
      end
  end
end
