require 'logger'
require 'abstract_unit'
require 'active_support/cache'

class CacheKeyTest < ActiveSupport::TestCase
  def test_expand_cache_key
    assert_equal '1/2/true', ActiveSupport::Cache.expand_cache_key([1, '2', true])
    assert_equal 'name/1/2/true', ActiveSupport::Cache.expand_cache_key([1, '2', true], :name)
  end

  def test_expand_cache_key_with_rails_cache_id
    begin
      ENV['RAILS_CACHE_ID'] = 'c99'
      assert_equal 'c99/foo', ActiveSupport::Cache.expand_cache_key(:foo)
      assert_equal 'c99/foo', ActiveSupport::Cache.expand_cache_key([:foo])
      assert_equal 'c99/c99/foo/c99/bar', ActiveSupport::Cache.expand_cache_key([:foo, :bar])
      assert_equal 'nm/c99/foo', ActiveSupport::Cache.expand_cache_key(:foo, :nm)
      assert_equal 'nm/c99/foo', ActiveSupport::Cache.expand_cache_key([:foo], :nm)
      assert_equal 'nm/c99/c99/foo/c99/bar', ActiveSupport::Cache.expand_cache_key([:foo, :bar], :nm)
    ensure
      ENV['RAILS_CACHE_ID'] = nil
    end
  end

  def test_expand_cache_key_with_rails_app_version
    begin
      ENV['RAILS_APP_VERSION'] = 'rails3'
      assert_equal 'rails3/foo', ActiveSupport::Cache.expand_cache_key(:foo)
    ensure
      ENV['RAILS_APP_VERSION'] = nil
    end
  end

  def test_expand_cache_key_rails_cache_id_should_win_over_rails_app_version
    begin
      ENV['RAILS_CACHE_ID'] = 'c99'
      ENV['RAILS_APP_VERSION'] = 'rails3'
      assert_equal 'c99/foo', ActiveSupport::Cache.expand_cache_key(:foo)
    ensure
      ENV['RAILS_CACHE_ID'] = nil
      ENV['RAILS_APP_VERSION'] = nil
    end
  end

  def test_respond_to_cache_key
    key = 'foo'
    def key.cache_key
      :foo_key
    end
    assert_equal 'foo_key', ActiveSupport::Cache.expand_cache_key(key)
  end

end

class CacheStoreSettingTest < ActiveSupport::TestCase
  def test_file_fragment_cache_store
    store = ActiveSupport::Cache.lookup_store :file_store, "/path/to/cache/directory"
    assert_kind_of(ActiveSupport::Cache::FileStore, store)
    assert_equal "/path/to/cache/directory", store.cache_path
  end

  def test_mem_cache_fragment_cache_store
    MemCache.expects(:new).with(%w[localhost], {})
    store = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost"
    assert_kind_of(ActiveSupport::Cache::MemCacheStore, store)
  end

  def test_mem_cache_fragment_cache_store_with_given_mem_cache
    mem_cache = MemCache.new
    MemCache.expects(:new).never
    store = ActiveSupport::Cache.lookup_store :mem_cache_store, mem_cache
    assert_kind_of(ActiveSupport::Cache::MemCacheStore, store)
  end

  def test_mem_cache_fragment_cache_store_with_given_mem_cache_like_object
    MemCache.expects(:new).never
    memcache = Object.new
    def memcache.get() true end
    store = ActiveSupport::Cache.lookup_store :mem_cache_store, memcache
    assert_kind_of(ActiveSupport::Cache::MemCacheStore, store)
  end

  def test_mem_cache_fragment_cache_store_with_multiple_servers
    MemCache.expects(:new).with(%w[localhost 192.168.1.1], {})
    store = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost", '192.168.1.1'
    assert_kind_of(ActiveSupport::Cache::MemCacheStore, store)
  end

  def test_mem_cache_fragment_cache_store_with_options
    MemCache.expects(:new).with(%w[localhost 192.168.1.1], { :timeout => 10 })
    store = ActiveSupport::Cache.lookup_store :mem_cache_store, "localhost", '192.168.1.1', :namespace => 'foo', :timeout => 10
    assert_kind_of(ActiveSupport::Cache::MemCacheStore, store)
    assert_equal 'foo', store.options[:namespace]
  end

  def test_object_assigned_fragment_cache_store
    store = ActiveSupport::Cache.lookup_store ActiveSupport::Cache::FileStore.new("/path/to/cache/directory")
    assert_kind_of(ActiveSupport::Cache::FileStore, store)
    assert_equal "/path/to/cache/directory", store.cache_path
  end
end

class CacheStoreNamespaceTest < ActiveSupport::TestCase
  def test_static_namespace
    cache = ActiveSupport::Cache.lookup_store(:memory_store, :namespace => "tester")
    cache.write("foo", "bar")
    assert_equal "bar", cache.read("foo")
    assert_equal "bar", cache.instance_variable_get(:@data)["tester:foo"].value
  end

  def test_proc_namespace
    test_val = "tester"
    proc = lambda{test_val}
    cache = ActiveSupport::Cache.lookup_store(:memory_store, :namespace => proc)
    cache.write("foo", "bar")
    assert_equal "bar", cache.read("foo")
    assert_equal "bar", cache.instance_variable_get(:@data)["tester:foo"].value
  end

  def test_delete_matched_key_start
    cache = ActiveSupport::Cache.lookup_store(:memory_store, :namespace => "tester")
    cache.write("foo", "bar")
    cache.write("fu", "baz")
    cache.delete_matched(/^fo/)
    assert_equal false, cache.exist?("foo")
    assert_equal true, cache.exist?("fu")
  end

  def test_delete_matched_key
    cache = ActiveSupport::Cache.lookup_store(:memory_store, :namespace => "foo")
    cache.write("foo", "bar")
    cache.write("fu", "baz")
    cache.delete_matched(/OO/i)
    assert_equal false, cache.exist?("foo")
    assert_equal true, cache.exist?("fu")
  end
end

# Tests the base functionality that should be identical across all cache stores.
module CacheStoreBehavior
  def test_should_read_and_write_strings
    assert_equal true, @cache.write('foo', 'bar')
    assert_equal 'bar', @cache.read('foo')
  end

  def test_should_overwrite
    @cache.write('foo', 'bar')
    @cache.write('foo', 'baz')
    assert_equal 'baz', @cache.read('foo')
  end

  def test_fetch_without_cache_miss
    @cache.write('foo', 'bar')
    @cache.expects(:write).never
    assert_equal 'bar', @cache.fetch('foo') { 'baz' }
  end

  def test_fetch_with_cache_miss
    @cache.expects(:write).with('foo', 'baz', @cache.options)
    assert_equal 'baz', @cache.fetch('foo') { 'baz' }
  end

  def test_fetch_with_forced_cache_miss
    @cache.write('foo', 'bar')
    @cache.expects(:read).never
    @cache.expects(:write).with('foo', 'bar', @cache.options.merge(:force => true))
    @cache.fetch('foo', :force => true) { 'bar' }
  end

  def test_fetch_with_cached_nil
    @cache.write('foo', nil)
    @cache.expects(:write).never
    assert_nil @cache.fetch('foo') { 'baz' }
  end

  def test_should_read_and_write_hash
    assert_equal true, @cache.write('foo', {:a => "b"})
    assert_equal({:a => "b"}, @cache.read('foo'))
  end

  def test_should_read_and_write_integer
    assert_equal true, @cache.write('foo', 1)
    assert_equal 1, @cache.read('foo')
  end

  def test_should_read_and_write_nil
    assert_equal true, @cache.write('foo', nil)
    assert_equal nil, @cache.read('foo')
  end

  def test_read_multi
    @cache.write('foo', 'bar')
    @cache.write('fu', 'baz')
    @cache.write('fud', 'biz')
    assert_equal({"foo" => "bar", "fu" => "baz"}, @cache.read_multi('foo', 'fu'))
  end

  def test_read_and_write_compressed_small_data
    @cache.write('foo', 'bar', :compress => true)
    raw_value = @cache.send(:read_entry, 'foo', {}).raw_value
    assert_equal 'bar', @cache.read('foo')
    assert_equal 'bar', raw_value
  end

  def test_read_and_write_compressed_large_data
    @cache.write('foo', 'bar', :compress => true, :compress_threshold => 2)
    raw_value = @cache.send(:read_entry, 'foo', {}).raw_value
    assert_equal 'bar', @cache.read('foo')
    assert_equal 'bar', Marshal.load(Zlib::Inflate.inflate(raw_value))
  end

  def test_read_and_write_compressed_nil
    @cache.write('foo', nil, :compress => true)
    assert_nil @cache.read('foo')
  end

  def test_cache_key
    obj = Object.new
    def obj.cache_key
      :foo
    end
    @cache.write(obj, "bar")
    assert_equal "bar", @cache.read("foo")
  end

  def test_param_as_cache_key
    obj = Object.new
    def obj.to_param
      "foo"
    end
    @cache.write(obj, "bar")
    assert_equal "bar", @cache.read("foo")
  end

  def test_array_as_cache_key
    @cache.write([:fu, "foo"], "bar")
    assert_equal "bar", @cache.read("fu/foo")
  end

  def test_hash_as_cache_key
    @cache.write({:foo => 1, :fu => 2}, "bar")
    assert_equal "bar", @cache.read("foo=1/fu=2")
  end

  def test_keys_are_case_sensitive
    @cache.write("foo", "bar")
    assert_nil @cache.read("FOO")
  end

  def test_exist
    @cache.write('foo', 'bar')
    assert_equal true, @cache.exist?('foo')
    assert_equal false, @cache.exist?('bar')
  end

  def test_nil_exist
    @cache.write('foo', nil)
    assert_equal true, @cache.exist?('foo')
  end

  def test_delete
    @cache.write('foo', 'bar')
    assert @cache.exist?('foo')
    assert_equal true, @cache.delete('foo')
    assert !@cache.exist?('foo')
  end

  def test_store_objects_should_be_immutable
    @cache.write('foo', 'bar')
    assert_raise(ActiveSupport::FrozenObjectError) { @cache.read('foo').gsub!(/.*/, 'baz') }
    assert_equal 'bar', @cache.read('foo')
  end

  def test_original_store_objects_should_not_be_immutable
    bar = 'bar'
    @cache.write('foo', bar)
    assert_nothing_raised { bar.gsub!(/.*/, 'baz') }
  end

  def test_expires_in
    time = Time.local(2008, 4, 24)
    Time.stubs(:now).returns(time)

    @cache.write('foo', 'bar')
    assert_equal 'bar', @cache.read('foo')

    Time.stubs(:now).returns(time + 30)
    assert_equal 'bar', @cache.read('foo')

    Time.stubs(:now).returns(time + 61)
    assert_nil @cache.read('foo')
  end

  def test_race_condition_protection
    time = Time.now
    @cache.write('foo', 'bar', :expires_in => 60)
    Time.stubs(:now).returns(time + 61)
    result = @cache.fetch('foo', :race_condition_ttl => 10) do
      assert_equal 'bar', @cache.read('foo')
      "baz"
    end
    assert_equal "baz", result
  end

  def test_race_condition_protection_is_limited
    time = Time.now
    @cache.write('foo', 'bar', :expires_in => 60)
    Time.stubs(:now).returns(time + 71)
    result = @cache.fetch('foo', :race_condition_ttl => 10) do
      assert_equal nil, @cache.read('foo')
      "baz"
    end
    assert_equal "baz", result
  end

  def test_race_condition_protection_is_safe
    time = Time.now
    @cache.write('foo', 'bar', :expires_in => 60)
    Time.stubs(:now).returns(time + 61)
    begin
      @cache.fetch('foo', :race_condition_ttl => 10) do
        assert_equal 'bar', @cache.read('foo')
        raise ArgumentError.new
      end
    rescue ArgumentError
    end
    assert_equal "bar", @cache.read('foo')
    Time.stubs(:now).returns(time + 71)
    assert_nil @cache.read('foo')
  end

  def test_crazy_key_characters
    crazy_key = "#/:*(<+=> )&$%@?;'\"\'`~-"
    assert_equal true, @cache.write(crazy_key, "1", :raw => true)
    assert_equal "1", @cache.read(crazy_key)
    assert_equal "1", @cache.fetch(crazy_key)
    assert_equal true, @cache.delete(crazy_key)
    assert_equal "2", @cache.fetch(crazy_key, :raw => true) { "2" }
    assert_equal 3, @cache.increment(crazy_key)
    assert_equal 2, @cache.decrement(crazy_key)
  end

  def test_really_long_keys
    key = ""
    1000.times{key << "x"}
    assert_equal true, @cache.write(key, "bar")
    assert_equal "bar", @cache.read(key)
    assert_equal "bar", @cache.fetch(key)
    assert_nil @cache.read("#{key}x")
    assert_equal({key => "bar"}, @cache.read_multi(key))
    assert_equal true, @cache.delete(key)
  end
end

module CacheDeleteMatchedBehavior
  def test_delete_matched
    @cache.write("foo", "bar")
    @cache.write("fu", "baz")
    @cache.delete_matched(/oo/)
    assert_equal false, @cache.exist?("foo")
    assert_equal true, @cache.exist?("fu")
  end
end

module CacheIncrementDecrementBehavior
  def test_increment
    @cache.write('foo', 1, :raw => true)
    assert_equal 1, @cache.read('foo').to_i
    assert_equal 2, @cache.increment('foo')
    assert_equal 2, @cache.read('foo').to_i
    assert_equal 3, @cache.increment('foo')
    assert_equal 3, @cache.read('foo').to_i
  end

  def test_decrement
    @cache.write('foo', 3, :raw => true)
    assert_equal 3, @cache.read('foo').to_i
    assert_equal 2, @cache.decrement('foo')
    assert_equal 2, @cache.read('foo').to_i
    assert_equal 1, @cache.decrement('foo')
    assert_equal 1, @cache.read('foo').to_i
  end
end

module LocalCacheBehavior
  def test_local_writes_are_persistent_on_the_remote_cache
    retval = @cache.with_local_cache do
      @cache.write('foo', 'bar')
    end
    assert_equal true, retval
    assert_equal 'bar', @cache.read('foo')
  end

  def test_clear_also_clears_local_cache
    @cache.with_local_cache do
      @cache.write('foo', 'bar')
      @cache.clear
      assert_nil @cache.read('foo')
    end

    assert_nil @cache.read('foo')
  end

  def test_local_cache_of_write
    @cache.with_local_cache do
      @cache.write('foo', 'bar')
      @peek.delete('foo')
      assert_equal 'bar', @cache.read('foo')
    end
  end

  def test_local_cache_of_read
    @cache.write('foo', 'bar')
    @cache.with_local_cache do
      assert_equal 'bar', @cache.read('foo')
    end
  end

  def test_local_cache_of_write_nil
    @cache.with_local_cache do
      assert @cache.write('foo', nil)
      assert_nil @cache.read('foo')
      @peek.write('foo', 'bar')
      assert_nil @cache.read('foo')
    end
  end

  def test_local_cache_of_delete
    @cache.with_local_cache do
      @cache.write('foo', 'bar')
      @cache.delete('foo')
      assert_nil @cache.read('foo')
    end
  end

  def test_local_cache_of_exist
    @cache.with_local_cache do
      @cache.write('foo', 'bar')
      @peek.delete('foo')
      assert @cache.exist?('foo')
    end
  end

  def test_local_cache_of_increment
    @cache.with_local_cache do
      @cache.write('foo', 1, :raw => true)
      @peek.write('foo', 2, :raw => true)
      @cache.increment('foo')
      assert_equal 3, @cache.read('foo')
    end
  end

  def test_local_cache_of_decrement
    @cache.with_local_cache do
      @cache.write('foo', 1, :raw => true)
      @peek.write('foo', 3, :raw => true)
      @cache.decrement('foo')
      assert_equal 2, @cache.read('foo')
    end
  end

  def test_middleware
    app = lambda { |env|
      result = @cache.write('foo', 'bar')
      assert_equal 'bar', @cache.read('foo') # make sure 'foo' was written
      assert result
    }
    app = @cache.middleware.new(app)
    app.call({})
  end
end

class FileStoreTest < ActiveSupport::TestCase
  def setup
    Dir.mkdir(cache_dir) unless File.exist?(cache_dir)
    @cache = ActiveSupport::Cache.lookup_store(:file_store, cache_dir, :expires_in => 60)
    @peek = ActiveSupport::Cache.lookup_store(:file_store, cache_dir, :expires_in => 60)
  end

  def teardown
    FileUtils.rm_r(cache_dir)
  end

  def cache_dir
    File.join(Dir.pwd, 'tmp_cache')
  end

  include CacheStoreBehavior
  include LocalCacheBehavior
  include CacheDeleteMatchedBehavior
  include CacheIncrementDecrementBehavior

  def test_deprecated_expires_in_on_read
    ActiveSupport::Deprecation.silence do
      old_cache = ActiveSupport::Cache.lookup_store(:file_store, cache_dir)

      time = Time.local(2008, 4, 24)
      Time.stubs(:now).returns(time)

      old_cache.write("foo", "bar")
      assert_equal 'bar', old_cache.read('foo', :expires_in => 60)

      Time.stubs(:now).returns(time + 30)
      assert_equal 'bar', old_cache.read('foo', :expires_in => 60)

      Time.stubs(:now).returns(time + 61)
      assert_equal 'bar', old_cache.read('foo')
      assert_nil old_cache.read('foo', :expires_in => 60)
      assert_nil old_cache.read('foo')
    end
  end
end

class MemoryStoreTest < ActiveSupport::TestCase
  def setup
    @cache = ActiveSupport::Cache.lookup_store(:memory_store, :expires_in => 60, :size => 100)
  end

  include CacheStoreBehavior
  include CacheDeleteMatchedBehavior
  include CacheIncrementDecrementBehavior

  def test_prune_size
    @cache.write(1, "aaaaaaaaaa") && sleep(0.001)
    @cache.write(2, "bbbbbbbbbb") && sleep(0.001)
    @cache.write(3, "cccccccccc") && sleep(0.001)
    @cache.write(4, "dddddddddd") && sleep(0.001)
    @cache.write(5, "eeeeeeeeee") && sleep(0.001)
    @cache.read(2) && sleep(0.001)
    @cache.read(4)
    @cache.prune(30)
    assert_equal true, @cache.exist?(5)
    assert_equal true, @cache.exist?(4)
    assert_equal false, @cache.exist?(3)
    assert_equal true, @cache.exist?(2)
    assert_equal false, @cache.exist?(1)
  end

  def test_prune_size_on_write
    @cache.write(1, "aaaaaaaaaa") && sleep(0.001)
    @cache.write(2, "bbbbbbbbbb") && sleep(0.001)
    @cache.write(3, "cccccccccc") && sleep(0.001)
    @cache.write(4, "dddddddddd") && sleep(0.001)
    @cache.write(5, "eeeeeeeeee") && sleep(0.001)
    @cache.write(6, "ffffffffff") && sleep(0.001)
    @cache.write(7, "gggggggggg") && sleep(0.001)
    @cache.write(8, "hhhhhhhhhh") && sleep(0.001)
    @cache.write(9, "iiiiiiiiii") && sleep(0.001)
    @cache.write(10, "kkkkkkkkkk") && sleep(0.001)
    @cache.read(2) && sleep(0.001)
    @cache.read(4) && sleep(0.001)
    @cache.write(11, "llllllllll")
    assert_equal true, @cache.exist?(11)
    assert_equal true, @cache.exist?(10)
    assert_equal true, @cache.exist?(9)
    assert_equal true, @cache.exist?(8)
    assert_equal true, @cache.exist?(7)
    assert_equal false, @cache.exist?(6)
    assert_equal false, @cache.exist?(5)
    assert_equal true, @cache.exist?(4)
    assert_equal false, @cache.exist?(3)
    assert_equal true, @cache.exist?(2)
    assert_equal false, @cache.exist?(1)
  end

  def test_pruning_is_capped_at_a_max_time
    def @cache.delete_entry (*args)
      sleep(0.01)
      super
    end
    @cache.write(1, "aaaaaaaaaa") && sleep(0.001)
    @cache.write(2, "bbbbbbbbbb") && sleep(0.001)
    @cache.write(3, "cccccccccc") && sleep(0.001)
    @cache.write(4, "dddddddddd") && sleep(0.001)
    @cache.write(5, "eeeeeeeeee") && sleep(0.001)
    @cache.prune(30, 0.001)
    assert_equal true, @cache.exist?(5)
    assert_equal true, @cache.exist?(4)
    assert_equal true, @cache.exist?(3)
    assert_equal true, @cache.exist?(2)
    assert_equal false, @cache.exist?(1)
  end
end

class SynchronizedStoreTest < ActiveSupport::TestCase
  def setup
    ActiveSupport::Deprecation.silence do
      @cache = ActiveSupport::Cache.lookup_store(:memory_store, :expires_in => 60)
    end
  end

  include CacheStoreBehavior
  include CacheDeleteMatchedBehavior
  include CacheIncrementDecrementBehavior
end

uses_memcached 'memcached backed store' do
  class MemCacheStoreTest < ActiveSupport::TestCase
    def setup
      @cache = ActiveSupport::Cache.lookup_store(:mem_cache_store, :expires_in => 60)
      @peek = ActiveSupport::Cache.lookup_store(:mem_cache_store)
      @data = @cache.instance_variable_get(:@data)
      @cache.clear
      @cache.silence!
      @cache.logger = Logger.new("/dev/null")
    end

    include CacheStoreBehavior
    include LocalCacheBehavior
    include CacheIncrementDecrementBehavior

    def test_raw_values
      cache = ActiveSupport::Cache.lookup_store(:mem_cache_store, :raw => true)
      cache.clear
      cache.write("foo", 2)
      assert_equal "2", cache.read("foo")
    end

    def test_local_cache_raw_values
      cache = ActiveSupport::Cache.lookup_store(:mem_cache_store, :raw => true)
      cache.clear
      cache.with_local_cache do
        cache.write("foo", 2)
        assert_equal "2", cache.read("foo")
      end
    end
  end

  class CompressedMemCacheStore < ActiveSupport::TestCase
    def setup
      ActiveSupport::Deprecation.silence do
        @cache = ActiveSupport::Cache.lookup_store(:compressed_mem_cache_store, :expires_in => 60)
        @cache.clear
      end
    end

    include CacheStoreBehavior
    include CacheIncrementDecrementBehavior
  end
end

class CacheStoreLoggerTest < ActiveSupport::TestCase
  def setup
    @cache = ActiveSupport::Cache.lookup_store(:memory_store)

    @buffer = StringIO.new
    @cache.logger = Logger.new(@buffer)
  end

  def test_logging
    @cache.fetch('foo') { 'bar' }
    assert @buffer.string.present?
  end

  def test_mute_logging
    @cache.mute { @cache.fetch('foo') { 'bar' } }
    assert @buffer.string.blank?
  end
end

class CacheEntryTest < ActiveSupport::TestCase
  def test_create_raw_entry
    time = Time.now
    entry = ActiveSupport::Cache::Entry.create("raw", time, :compress => false, :expires_in => 300)
    assert_equal "raw", entry.raw_value
    assert_equal time.to_f, entry.created_at
    assert_equal false, entry.compressed?
    assert_equal 300, entry.expires_in
  end

  def test_expired
    entry = ActiveSupport::Cache::Entry.new("value")
    assert_equal false, entry.expired?
    entry = ActiveSupport::Cache::Entry.new("value", :expires_in => 60)
    assert_equal false, entry.expired?
    time = Time.now + 61
    Time.stubs(:now).returns(time)
    assert_equal true, entry.expired?
  end

  def test_compress_values
    entry = ActiveSupport::Cache::Entry.new("value", :compress => true, :compress_threshold => 1)
    assert_equal "value", entry.value
    assert_equal true, entry.compressed?
    assert_equal "value", Marshal.load(Zlib::Inflate.inflate(entry.raw_value))
  end

  def test_non_compress_values
    entry = ActiveSupport::Cache::Entry.new("value")
    assert_equal "value", entry.value
    assert_equal "value", entry.raw_value
    assert_equal false, entry.compressed?
  end
end
