class TestNested < MiniTest::Unit::TestCase
  def setup
    MethodArgs.load(~'fixtures/5')
  end

  def test_nested
    assert_equal 0, Top.instance_method(:one).args.count
    assert_equal 1, Top::Middle.instance_method(:one).args.count
    assert_equal 0, Top::Middle.instance_method(:two).args.count
    assert_equal 1, Top::Middle::End.instance_method(:two).args.count
  end
end