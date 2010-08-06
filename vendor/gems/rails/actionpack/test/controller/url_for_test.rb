require 'abstract_unit'

module AbstractController
  module Testing

    class UrlForTests < ActionController::TestCase
      class W
        include SharedTestRoutes.url_helpers
      end

      def teardown
        W.default_url_options.clear
      end

      def add_host!
        W.default_url_options[:host] = 'www.basecamphq.com'
      end

      def test_exception_is_thrown_without_host
        assert_raise RuntimeError do
          W.new.url_for :controller => 'c', :action => 'a', :id => 'i'
        end
      end

      def test_anchor
        assert_equal('/c/a#anchor',
          W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :anchor => 'anchor')
        )
      end

      def test_anchor_should_call_to_param
        assert_equal('/c/a#anchor',
          W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :anchor => Struct.new(:to_param).new('anchor'))
        )
      end

      def test_anchor_should_escape_unsafe_pchar
        assert_equal('/c/a#%23anchor',
          W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :anchor => Struct.new(:to_param).new('#anchor'))
        )
      end

      def test_anchor_should_not_escape_safe_pchar
        assert_equal('/c/a#name=user&email=user@domain.com',
          W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :anchor => Struct.new(:to_param).new('name=user&email=user@domain.com'))
        )
      end

      def test_default_host
        add_host!
        assert_equal('http://www.basecamphq.com/c/a/i',
          W.new.url_for(:controller => 'c', :action => 'a', :id => 'i')
        )
      end

      def test_host_may_be_overridden
        add_host!
        assert_equal('http://37signals.basecamphq.com/c/a/i',
          W.new.url_for(:host => '37signals.basecamphq.com', :controller => 'c', :action => 'a', :id => 'i')
        )
      end

      def test_port
        add_host!
        assert_equal('http://www.basecamphq.com:3000/c/a/i',
          W.new.url_for(:controller => 'c', :action => 'a', :id => 'i', :port => 3000)
        )
      end

      def test_protocol
        add_host!
        assert_equal('https://www.basecamphq.com/c/a/i',
          W.new.url_for(:controller => 'c', :action => 'a', :id => 'i', :protocol => 'https')
        )
      end

      def test_protocol_with_and_without_separator
        add_host!
        assert_equal('https://www.basecamphq.com/c/a/i',
          W.new.url_for(:controller => 'c', :action => 'a', :id => 'i', :protocol => 'https')
        )
        assert_equal('https://www.basecamphq.com/c/a/i',
          W.new.url_for(:controller => 'c', :action => 'a', :id => 'i', :protocol => 'https://')
        )
      end

      def test_trailing_slash
        add_host!
        options = {:controller => 'foo', :trailing_slash => true, :action => 'bar', :id => '33'}
        assert_equal('http://www.basecamphq.com/foo/bar/33/', W.new.url_for(options) )
      end

      def test_trailing_slash_with_protocol
        add_host!
        options = { :trailing_slash => true,:protocol => 'https', :controller => 'foo', :action => 'bar', :id => '33'}
        assert_equal('https://www.basecamphq.com/foo/bar/33/', W.new.url_for(options) )
        assert_equal 'https://www.basecamphq.com/foo/bar/33/?query=string', W.new.url_for(options.merge({:query => 'string'}))
      end

      def test_trailing_slash_with_only_path
        options = {:controller => 'foo', :trailing_slash => true}
        assert_equal '/foo/', W.new.url_for(options.merge({:only_path => true}))
        options.update({:action => 'bar', :id => '33'})
        assert_equal '/foo/bar/33/', W.new.url_for(options.merge({:only_path => true}))
        assert_equal '/foo/bar/33/?query=string', W.new.url_for(options.merge({:query => 'string',:only_path => true}))
      end

      def test_trailing_slash_with_anchor
        options = {:trailing_slash => true, :controller => 'foo', :action => 'bar', :id => '33', :only_path => true, :anchor=> 'chapter7'}
        assert_equal '/foo/bar/33/#chapter7', W.new.url_for(options)
        assert_equal '/foo/bar/33/?query=string#chapter7', W.new.url_for(options.merge({:query => 'string'}))
      end

      def test_trailing_slash_with_params
        url = W.new.url_for(:trailing_slash => true, :only_path => true, :controller => 'cont', :action => 'act', :p1 => 'cafe', :p2 => 'link')
        params = extract_params(url)
        assert_equal params[0], { :p1 => 'cafe' }.to_query
        assert_equal params[1], { :p2 => 'link' }.to_query
      end

      def test_relative_url_root_is_respected
        # ROUTES TODO: Tests should not have to pass :relative_url_root directly. This
        # should probably come from routes.

        add_host!
        assert_equal('https://www.basecamphq.com/subdir/c/a/i',
          W.new.url_for(:controller => 'c', :action => 'a', :id => 'i', :protocol => 'https', :script_name => '/subdir')
        )
      end

      def test_named_routes
        with_routing do |set|
          set.draw do |map|
            match 'this/is/verbose', :to => 'home#index', :as => :no_args
            match 'home/sweet/home/:user', :to => 'home#index', :as => :home
          end

          # We need to create a new class in order to install the new named route.
          kls = Class.new { include set.url_helpers }

          controller = kls.new
          assert controller.respond_to?(:home_url)
          assert_equal 'http://www.basecamphq.com/home/sweet/home/again',
            controller.send(:home_url, :host => 'www.basecamphq.com', :user => 'again')

          assert_equal("/home/sweet/home/alabama", controller.send(:home_path, :user => 'alabama', :host => 'unused'))
          assert_equal("http://www.basecamphq.com/home/sweet/home/alabama", controller.send(:home_url, :user => 'alabama', :host => 'www.basecamphq.com'))
          assert_equal("http://www.basecamphq.com/this/is/verbose", controller.send(:no_args_url, :host=>'www.basecamphq.com'))
        end
      end

      def test_relative_url_root_is_respected_for_named_routes
        with_routing do |set|
          set.draw do |map|
            match '/home/sweet/home/:user', :to => 'home#index', :as => :home
          end

          kls = Class.new { include set.url_helpers }
          controller = kls.new

          assert_equal 'http://www.basecamphq.com/subdir/home/sweet/home/again',
            controller.send(:home_url, :host => 'www.basecamphq.com', :user => 'again', :script_name => "/subdir")
        end
      end

      def test_only_path
        with_routing do |set|
          set.draw do |map|
            match 'home/sweet/home/:user', :to => 'home#index', :as => :home
            match ':controller/:action/:id'
          end

          # We need to create a new class in order to install the new named route.
          kls = Class.new { include set.url_helpers }
          controller = kls.new
          assert controller.respond_to?(:home_url)
          assert_equal '/brave/new/world',
            controller.send(:url_for, :controller => 'brave', :action => 'new', :id => 'world', :only_path => true)

          assert_equal("/home/sweet/home/alabama", controller.send(:home_url, :user => 'alabama', :host => 'unused', :only_path => true))
          assert_equal("/home/sweet/home/alabama", controller.send(:home_path, 'alabama'))
        end
      end

      def test_one_parameter
        assert_equal('/c/a?param=val',
          W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :param => 'val')
        )
      end

      def test_two_parameters
        url = W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :p1 => 'X1', :p2 => 'Y2')
        params = extract_params(url)
        assert_equal params[0], { :p1 => 'X1' }.to_query
        assert_equal params[1], { :p2 => 'Y2' }.to_query
      end

      def test_hash_parameter
        url = W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :query => {:name => 'Bob', :category => 'prof'})
        params = extract_params(url)
        assert_equal params[0], { 'query[category]' => 'prof' }.to_query
        assert_equal params[1], { 'query[name]'     => 'Bob'  }.to_query
      end

      def test_array_parameter
        url = W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :query => ['Bob', 'prof'])
        params = extract_params(url)
        assert_equal params[0], { 'query[]' => 'Bob'  }.to_query
        assert_equal params[1], { 'query[]' => 'prof' }.to_query
      end

      def test_hash_recursive_parameters
        url = W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :query => {:person => {:name => 'Bob', :position => 'prof'}, :hobby => 'piercing'})
        params = extract_params(url)
        assert_equal params[0], { 'query[hobby]'            => 'piercing' }.to_query
        assert_equal params[1], { 'query[person][name]'     => 'Bob'      }.to_query
        assert_equal params[2], { 'query[person][position]' => 'prof'     }.to_query
      end

      def test_hash_recursive_and_array_parameters
        url = W.new.url_for(:only_path => true, :controller => 'c', :action => 'a', :id => 101, :query => {:person => {:name => 'Bob', :position => ['prof', 'art director']}, :hobby => 'piercing'})
        assert_match %r(^/c/a/101), url
        params = extract_params(url)
        assert_equal params[0], { 'query[hobby]'              => 'piercing'     }.to_query
        assert_equal params[1], { 'query[person][name]'       => 'Bob'          }.to_query
        assert_equal params[2], { 'query[person][position][]' => 'art director' }.to_query
        assert_equal params[3], { 'query[person][position][]' => 'prof'         }.to_query
      end

      def test_path_generation_for_symbol_parameter_keys
        assert_generates("/image", :controller=> :image)
      end

      def test_named_routes_with_nil_keys
        with_routing do |set|
          set.draw do |map|
            match 'posts.:format', :to => 'posts#index', :as => :posts
            match '/', :to => 'posts#index', :as => :main
          end

          # We need to create a new class in order to install the new named route.
          kls = Class.new { include set.url_helpers }
          kls.default_url_options[:host] = 'www.basecamphq.com'

          controller = kls.new
          params = {:action => :index, :controller => :posts, :format => :xml}
          assert_equal("http://www.basecamphq.com/posts.xml", controller.send(:url_for, params))
          params[:format] = nil
          assert_equal("http://www.basecamphq.com/", controller.send(:url_for, params))
        end
      end

      def test_multiple_includes_maintain_distinct_options
        first_class = Class.new { include ActionController::UrlFor }
        second_class = Class.new { include ActionController::UrlFor }

        first_host, second_host = 'firsthost.com', 'secondhost.com'

        first_class.default_url_options[:host] = first_host
        second_class.default_url_options[:host] = second_host

        assert_equal first_class.default_url_options[:host], first_host
        assert_equal second_class.default_url_options[:host], second_host
      end

      def test_with_stringified_keys
        assert_equal("/c", W.new.url_for('controller' => 'c', 'only_path' => true))
        assert_equal("/c/a", W.new.url_for('controller' => 'c', 'action' => 'a', 'only_path' => true))
      end

      def test_with_hash_with_indifferent_access
        W.default_url_options[:controller] = 'd'
        W.default_url_options[:only_path]  = false
        assert_equal("/c", W.new.url_for(HashWithIndifferentAccess.new('controller' => 'c', 'only_path' => true)))

        W.default_url_options[:action] = 'b'
        assert_equal("/c/a", W.new.url_for(HashWithIndifferentAccess.new('controller' => 'c', 'action' => 'a', 'only_path' => true)))
      end

      private
        def extract_params(url)
          url.split('?', 2).last.split('&').sort
        end
    end
  end
end
