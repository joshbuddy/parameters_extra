class TestBlock < MiniTest::Unit::TestCase
  def setup
    MethodArgs.load(~'fixtures/3')
  end

  def test_block
    assert_equal [:required, :optional, :splat, :block], MyClass.instance_method(:block).args.types
  end
end