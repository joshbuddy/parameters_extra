class Two
  def one(hi, there)
  end
end

module TwoModule
  def mod(from, mod)
  end
end

class TwoSubclass < Two
  include TwoModule
  def two(one, more)
  end
end