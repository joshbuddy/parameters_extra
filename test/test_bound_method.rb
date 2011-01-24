class TestBoundMethod < MiniTest::Unit::TestCase
  def setup
    ParametersExtra.load(~'fixtures/1')
  end

  def test_default_args
    one = One.new
    one.two_method = 'happy times'
    two = One.new
    two.two_method = 'more happy times'
    assert_equal 'happy times',      one.method(:default_args_with_dependant_value).parameters_extra.last.default_value
    assert_equal 'more happy times', two.method(:default_args_with_dependant_value).parameters_extra.last.default_value
  end

  def test_binding_method
    method = One.instance_method(:default_args_with_dependant_value)
    one = One.new
    one.two_method = 'happy times'
    assert_equal 'happy times',      method.bind(one).parameters_extra.last.default_value
  end

end