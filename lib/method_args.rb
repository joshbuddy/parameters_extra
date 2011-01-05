require 'ruby2ruby'
require 'ruby_parser'
require 'sexp_processor'

module MethodMixin
  def args(trying_load = false)
    if !trying_load && respond_to?(:source_location) && !owner.const_defined?(:ArgList, false)
      file, line = source_location
      MethodArgs.load(file, false)
    end
    self.args = owner.const_get(:ArgList)[name.to_sym]
  end

  def args=(a)
    @args = a.clone
    @args.owning_method = self
    @args
  end
end

Method.send(:include, MethodMixin)
UnboundMethod.send(:include, MethodMixin)

module MethodArgs

  class ArgList < Array
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

      def default_value(receiver = nil)
        return nil if @default.nil?
        receiver ||= arg_list.owning_method.receiver if arg_list.owning_method.respond_to?(:receiver)
        raise "You must specify a receiver for the defaul value" if receiver.nil?
        raise "You must evaluate defaults in the context of a matching class. #{receiver.class.name} is not a #{@cls.name}." unless receiver.is_a?(arg_list.cls)
        receiver.instance_eval(@default)
      end
    end

    attr_accessor :owning_method
    attr_reader :cls

    def initialize(cls)
      @cls = cls
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

  def self.load(file, require_file = true)
    file = File.expand_path(file)
    require file if require_file
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
      arg_list = ArgList.new(current_class)
      while !exp.empty?
        t = exp.shift
        case t
        when Symbol
          arg_list << case t.to_s[0]
          when ?* then ArgList::Arg.new(t.to_s[1, t.to_s.size].to_sym, :splat)
          when ?& then ArgList::Arg.new(t.to_s[1, t.to_s.size].to_sym, :block)
          else         ArgList::Arg.new(t, :required)
          end
        when Sexp
          case t.shift
          when :block
            lasgn = t.shift
            lasgn.shift
            name = lasgn.shift
            new_arg = ArgList::Arg.new(name, :optional, @ruby2ruby.process(lasgn.last))
            arg_list.each_with_index{|arg, idx| arg_list[idx] = new_arg if arg.name == name}
          end
        end
      end
      @method_maps[current_classname][@current_method] = arg_list
      add_methods
    end

    def add_methods
      unless current_class.method(:const_defined?).arity == -1 ? current_class.const_defined?(:ArgList, false) : current_class.const_defined?(:ArgList)
        current_class.send(:const_set, :ArgList, @method_maps[current_classname])
        current_class.module_eval(<<-HERE_DOC, __FILE__, __LINE__)
          alias_method :__method__, :method
          
          class << self
            alias_method :__instance_method__, :instance_method unless method_defined?(:__instance_method__)
          end

          def self.instance_arg_list(method_name)
            method = __instance_method__(method_name)
            if method.owner == self
              ArgList[method_name] or raise('i don\\'t know this method ' + method_name.inspect)
            elsif method.owner.respond_to?(:instance_arg_list)
              method.owner.instance_arg_list(method_name)
            else
              raise \"\#{method.owner} has not been loaded with method_args\"
            end
          end

        HERE_DOC
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
