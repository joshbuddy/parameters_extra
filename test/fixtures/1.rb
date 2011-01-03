class One
  attr_accessor :two_method

  def no_args
  end

  def one_args(one)
  end
  
  def two_args(one, two)
  end

  def splat_args(one, two, *three)
  end

  def default_args(one, two = 'two')
  end

  def default_args_with_dependant_value(one, two = two_method)
  end
end
