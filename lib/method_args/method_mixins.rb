module MethodMixin
  def args
    MethodArgs.register(source_location[0]) if respond_to?(:source_location)
    args = MethodArgs.args_for_method(self).clone
    args.owning_method = self
    args
  end
end

Method.send(:include, MethodMixin)
UnboundMethod.send(:include, MethodMixin)