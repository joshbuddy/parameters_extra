class TestSubclass < MiniTest::Unit::TestCase
  def setup
    MethodArgs.load(~'fixtures/2')
  end

  def test_normal_visibility
    assert_equal [:one, :more], TwoSubclass.instance_method(:two).args.names
  end

  def test_superclass_visibility
    assert_equal [:hi, :there], TwoSubclass.instance_method(:one).args.names
  end

  def test_module_visibility
    assert_equal [:from, :mod], TwoSubclass.instance_method(:mod).args.names
  end
end
