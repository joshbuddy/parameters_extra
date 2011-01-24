module MethodMixin
  def parameters_extra
    ParametersExtra.register(source_location[0]) if respond_to?(:source_location)
    args = ParametersExtra.parameters_for_method(self).clone
    args.owning_method = self
    args
  end
end

Method.send(:include, MethodMixin)
UnboundMethod.send(:include, MethodMixin)