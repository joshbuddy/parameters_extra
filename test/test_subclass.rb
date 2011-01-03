class TestSubclass < MiniTest::Unit::TestCase
  def setup
    MethodArgs.load(~'fixtures/2')
  end

  def test_normal_visibility
    assert_equal [:one, :more], TwoSubclass.arg_list(:two).names
  end

  def test_superclass_visibility
    assert_equal [:hi, :there], TwoSubclass.arg_list(:one).names
  end

  def test_module_visibility
    assert_equal [:from, :mod], TwoSubclass.arg_list(:mod).names
  end
end
