class TestSimple < MiniTest::Unit::TestCase
  def setup
    ParametersExtra.load(~'fixtures/1')
  end

  def test_arg_counts
    assert_equal 0, One.instance_method(:no_args).parameters_extra.count
    assert_equal 1, One.instance_method(:one_args).parameters_extra.count
    assert_equal 2, One.instance_method(:two_args).parameters_extra.count
    assert_equal 3, One.instance_method(:splat_args).parameters_extra.count
    assert_equal 2, One.instance_method(:splat_args).parameters_extra.required_count
    assert_equal 2, One.instance_method(:default_args).parameters_extra.count
    assert_equal 1, One.instance_method(:default_args).parameters_extra.required_count
    assert_equal 2, One.instance_method(:default_args_with_dependant_value).parameters_extra.count
    assert_equal 1, One.instance_method(:default_args_with_dependant_value).parameters_extra.required_count
  end

  def test_arg_types
    assert_equal [],                                One.instance_method(:no_args).parameters_extra.types
    assert_equal [:required],                       One.instance_method(:one_args).parameters_extra.types
    assert_equal [:required, :required],            One.instance_method(:two_args).parameters_extra.types
    assert_equal [:required, :required, :splat],    One.instance_method(:splat_args).parameters_extra.types
    assert_equal [:required, :optional],            One.instance_method(:default_args).parameters_extra.types
    assert_equal [:required, :optional],            One.instance_method(:default_args_with_dependant_value).parameters_extra.types
  end

  def test_default_args
    one = One.new
    one.two_method = 'happy times'
    assert_equal 'happy times', One.instance_method(:default_args_with_dependant_value).bind(one).parameters_extra.last.default_value
  end

end