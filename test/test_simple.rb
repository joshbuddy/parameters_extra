class TestSimple < MiniTest::Unit::TestCase
  def setup
    MethodArgs.load(~'fixtures/1')
  end

  def test_arg_counts
    assert_equal 0, One.instance_method(:no_args).args.count
    assert_equal 1, One.instance_method(:one_args).args.count
    assert_equal 2, One.instance_method(:two_args).args.count
    assert_equal 3, One.instance_method(:splat_args).args.count
    assert_equal 2, One.instance_method(:splat_args).args.required_count
    assert_equal 2, One.instance_method(:default_args).args.count
    assert_equal 1, One.instance_method(:default_args).args.required_count
    assert_equal 2, One.instance_method(:default_args_with_dependant_value).args.count
    assert_equal 1, One.instance_method(:default_args_with_dependant_value).args.required_count
  end

  def test_arg_types
    assert_equal [],                              One.instance_method(:no_args).args.types
    assert_equal [:required],                     One.instance_method(:one_args).args.types
    assert_equal [:required, :required],          One.instance_method(:two_args).args.types
    assert_equal [:required, :required, :splat],  One.instance_method(:splat_args).args.types
    assert_equal [:required, :optional],          One.instance_method(:default_args).args.types
    assert_equal [:required, :optional],          One.instance_method(:default_args_with_dependant_value).args.types
  end

  def test_arg_method
    assert_equal One.instance_method(:no_args), One.instance_arg_list(:no_args).to_method
  end

  def test_default_args
    one = One.new
    one.two_method = 'happy times'
    assert_equal 'happy times', One.instance_method(:default_args_with_dependant_value).args.last.default_value(one)
  end

end