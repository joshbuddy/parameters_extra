module MethodArgs
  class Processor < SexpProcessor

    attr_reader :methods

    def initialize
      @methods = Hash.new{|h,k| h[k] = []}
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
      exp.shift
      exp
    end

    def process_args(exp)
      exp.shift
      arg_list = Args.new(@current_class.clone)
      while !exp.empty?
        t = exp.shift
        case t
        when Symbol
          arg_list << case t.to_s[0]
          when ?* then Args::Arg.new(t.to_s[1, t.to_s.size].to_sym, :splat)
          when ?& then Args::Arg.new(t.to_s[1, t.to_s.size].to_sym, :block)
          else         Args::Arg.new(t, :required)
          end
        when Sexp
          case t.shift
          when :block
            lasgn = t.shift
            lasgn.shift
            name = lasgn.shift
            new_arg = Args::Arg.new(name, :optional, @ruby2ruby.process(lasgn.last))
            arg_list.each_with_index{|arg, idx| arg_list[idx] = new_arg if arg.name == name}
          end
        end
      end
      @methods[current_classname] << [@current_method, arg_list]
    end

    def current_classname
      @current_class.map{|c| c.to_s}.join('::')
    end
  end
end