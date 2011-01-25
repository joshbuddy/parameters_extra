# ParametersExtra

## Purpose

You've got a method, but want to know more about the arguments? `#arity` and `#parameters` (if available) are useful,
but not nearly enough. You need something better. Like, the default arguments. *ParametersExtra* makes this simple. It operates
on a source file to supply the more details argument information by parsing the code itself.

## Usage

Pretend you have a file `your_ruby_file.rb`:

    class MyClass
      def initialize
        @default_value = 'hello'
      end

      def something(one, two = 'two', three = @default_value, *more, &block)
      end
    end

To look at the arguments to something and you're in Ruby 1.9 (please see https://twitter.com/igrigorik/status/19461463110320128), just require it normally:

    require 'your_ruby_file'
    MyClass.instance_method(:something).parameters_extra

Otherwise, do the following:
    
    ParametersExtra.load('your_ruby_file') # <-- this also requires the file
    MyClass.instance_method(:something).parameters_extra
    
This will return an `ArgList` object. You can then look at the names & types.

    MyClass.instance_method(:something).parameters_extra.names
    # => [:one, :two, :three, :more, :block]

    MyClass.instance_method(:something).parameters_extra.types
    # => [:required, :optional, :optional, :splat, :block]
    
If you want to get the value of a default argument, you'll need a context in which to evaluate it, namely,
an instance of the class from which the method derives.

    obj = MyClass.new
    obj.method(:something).parameters_extra.last.default_value
    # => 'hello'