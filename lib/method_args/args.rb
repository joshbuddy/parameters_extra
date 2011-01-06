module MethodArgs
  class Args < Array
    class Arg
    
      attr_accessor :arg_list
      attr_reader :name, :type
    
      def initialize(name, type, default = nil)
        @name, @type, @default = name, type, default
      end

      def required?
        @type == :required
      end

      def optional?
        @type == :optional
      end

      def splat?
        @type == :splat
      end

      def default?
        !@default.nil?
      end

      def default_value(receiver = nil)
        return nil if @default.nil?
        receiver ||= arg_list.owning_method.receiver if arg_list.owning_method.respond_to?(:receiver)
        raise "You must specify a receiver for the defaul value" if receiver.nil?
        raise "You must evaluate defaults in the context of a matching class. #{receiver.class.name} is not a #{arg_list.cls.name}." unless receiver.is_a?(arg_list.cls)
        receiver.instance_eval(@default)
      end
    end

    attr_accessor :owning_method

    def initialize(cls)
      @cls = cls
    end

    def cls
      @cls.inject(Module) {|c, m| c.const_get(m)}
    end

    def clone
      o = super
      o.each {|arg| arg.arg_list = o}
      o
    end

    def required_size
      inject(0) {|count, arg| count += arg.required? ? 1 : 0}
    end
    alias_method :required_count, :required_size

    def names
      map(&:name)
    end

    def types
      map(&:type)
    end
  end
end