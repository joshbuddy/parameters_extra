module MethodArgs
  class MethodRegistry < Hash
    attr_reader :method_names

    def initialize
      super
      @method_names = []
    end

    def add_methods!(methods)
      methods.each do |(method_name, args)|
        unless key?(method_name)
          self[method_name] = args
          method_names << method_name
        end
      end
    end
  end
end