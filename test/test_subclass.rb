class TestSubclass < MiniTest::Unit::TestCase
  def setup
    ParametersExtra.load(~'fixtures/2')
  end

  def test_normal_visibility
    assert_equal [:one, :more], TwoSubclass.instance_method(:two).parameters_extra.names
  end

  def test_subclass_overridding
    assert_equal [:hi, :there, :more], TwoSubclass.instance_method(:one).parameters_extra.names
  end

  def test_superclass_visibility
    assert_equal [:hi, :there], Two.instance_method(:one).parameters_extra.names
  end

  def test_module_visibility
    assert_equal [:from, :mod], TwoSubclass.instance_method(:mod).parameters_extra.names
  end
end
