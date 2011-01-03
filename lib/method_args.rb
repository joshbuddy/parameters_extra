require 'ruby2ruby'
require 'ruby_parser'
require 'sexp_processor'

class Method
  attr_accessor :args
end

module MethodArgs

  class ArgList < Array
    class Arg
      
      attr_reader :name, :type
      
      def initialize(cls, arg)
        @cls = cls
        @name = arg[0]
        @type = arg[1]
        @default = arg[2]
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

      def default_value(inst)
        return nil if @default.nil?
        raise "You must evaluate defaults in the context of a matching class. #{inst.class.name} is not a #{@cls.name}." unless inst.is_a?(@cls)
        inst.instance_eval(@default)
      end
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

    def initialize(cls, method)
      @cls, @method = cls, method
    end

    def to_method
      @cls.instance_method(@method)
    end
  end


  def self.load(file)
    file = File.expand_path(file)
    require file
    parser = RubyParser.new
    sexp = parser.process(File.read(File.exist?(file) ? file : "#{file}.rb"))
    method_args = Processor.new
    method_args.process(sexp)
  end

  class Processor < SexpProcessor

    attr_reader :method_maps

    def initialize
      @method_maps = Hash.new{|h,k| h[k] = {}}
      @current_class = []
      super()
    end

    def process_module(exp)
      exp.shift
      @current_class << exp.first.to_sym
      process(exp)
      @current_class.pop
      exp.clear
      exp
    end

    def process_class(exp)
      exp.shift
      current_class_size = @current_class.size
      case exp.first
      when Symbol
        @current_class << exp.first.to_sym
        process(exp)
      else
        if exp.first.first == :colon2
          exp.first.shift
          class_exp = exp.shift
          class_exp[0, class_exp.size - 1].each do |const|
            @current_class << const.last
          end
          @current_class << class_exp.last
        else
          raise
        end
        exp.shift
        process(exp.first)
      end
      @current_class.slice!(current_class_size, @current_class.size)
      exp.clear
      exp
    end

    def process_defn(exp)
      exp.shift
      @current_method = exp.shift
      @ruby2ruby = Ruby2Ruby.new
      process_args(exp.shift)
      scope = exp.shift
      exp
    end

    def process_args(exp)
      exp.shift
      arg_list = ArgList.new(current_class, @current_method)
      while !exp.empty?
        t = exp.shift
        case t
        when Symbol
          arg_list << if t.to_s[0] == ?*
            ArgList::Arg.new(current_class, [t.to_s[1, t.to_s.size].to_sym, :splat])
          else
            ArgList::Arg.new(current_class, [t, :required])
          end
        when Sexp
          case t.shift
          when :block
            lasgn = t.shift
            lasgn.shift
            name = lasgn.shift
            new_arg = ArgList::Arg.new(current_class, [name, :optional, @ruby2ruby.process(lasgn.last)])
            arg_list.each_with_index{|arg, idx| arg_list[idx] = new_arg if arg.name == name}
          end
        end
      end
      @method_maps[current_classname][@current_method] = arg_list
      add_methods
    end

    def add_methods
      unless current_class.const_defined?(:ArgList)
        current_class.send(:const_set, :ArgList, @method_maps[current_classname])
        current_class.module_eval "
          alias_method :old_method, :method
          alias_method :old_instance_method, :instance_method

          def self.instance_method(name)
            m = old_instance_method
            m.args = instance_arg_list(name)
            m
          end

          def self.instance_arg_list(method_name)
            method = instance_method(method_name)
            if owner == self
              ArgList[method_name]
            elsif owner.respond_to?(:arg_list)
              owner.arg_list(method_name)
            else
              raise \"\#{owner} has not been loaded with method_args\"
            end
          end
        "
      end
    end

    def current_classname
      @current_class.map{|c| c.to_s}.join('::')
    end

    def current_class
      @current_class.inject(Module) {|c, m| c.const_get(m)}
    end
  end
end
