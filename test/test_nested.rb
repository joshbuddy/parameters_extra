class TestNested < MiniTest::Unit::TestCase
  def setup
    ParametersExtra.load(~'fixtures/5')
  end

  def test_nested
    assert_equal 0, Top.instance_method(:one).parameters_extra.count
    assert_equal 1, Top::Middle.instance_method(:one).parameters_extra.count
    assert_equal 0, Top::Middle.instance_method(:two).parameters_extra.count
    assert_equal 1, Top::Middle::End.instance_method(:two).parameters_extra.count
  end
end