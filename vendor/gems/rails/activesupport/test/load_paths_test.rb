require 'abstract_unit'

class LoadPathsTest < Test::Unit::TestCase
  def test_uniq_load_paths
    load_paths_count = $LOAD_PATH.inject({}) { |paths, path|
      expanded_path = File.expand_path(path)
      paths[expanded_path] ||= 0
      paths[expanded_path] += 1
      paths
    }
    load_paths_count[File.expand_path('../../lib', __FILE__)] -= 1

    assert load_paths_count.select { |k, v| v > 1 }.empty?, $LOAD_PATH.inspect
  end
end
