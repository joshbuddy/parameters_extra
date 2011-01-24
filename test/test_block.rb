class TestBlock < MiniTest::Unit::TestCase
  def setup
    ParametersExtra.load(~'fixtures/3')
  end

  def test_block
    assert_equal [:required, :optional, :splat, :block], MyClass.instance_method(:block).parameters_extra.types
  end
end