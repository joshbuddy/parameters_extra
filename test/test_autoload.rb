if Method.instance_method(:source_location)
  class TestAutoload < MiniTest::Unit::TestCase
    def setup
      require ~'fixtures/4'
    end

    def test_arg_counts
      assert_equal 0, Autoloaded.instance_method(:some_method).parameters_extra.count
    end
  end
end rescue nil