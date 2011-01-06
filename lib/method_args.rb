require 'set'
require 'ruby2ruby'
require 'ruby_parser'
require 'sexp_processor'

require 'method_args/method_mixins'
require 'method_args/args'
require 'method_args/processor'
require 'method_args/version'
require 'method_args/method_registry'
module MethodArgs

  ClassMethodRegistry = Hash.new{|h, k| h[k] = MethodRegistry.new}
  FileRegistry = Set.new

  def self.load(file, require_file = true)
    require file if require_file
    register file
  end

  def self.args_for_method(method)
    k = class_key(method.owner)
    ClassMethodRegistry[k][method.name.to_sym] if ClassMethodRegistry.key?(k)
  end

  def self.register(file)
    file = expand_path(file)
    unless FileRegistry.include?(file)
      FileRegistry << file
      parse(file).each { |cls, methods| ClassMethodRegistry[cls].add_methods!(methods) }
    end
  end

  def self.parse(file, require_file = true)
    parser = RubyParser.new
    sexp = parser.process(File.read(expand_path(file)))
    method_args = Processor.new
    method_args.process(sexp)
    method_args.methods
  end

  def self.class_key(cls)
    nesting = cls.class_eval("Module.nesting")
    nesting.pop
    nesting.join('::')
  end

  def self.expand_path(file)
    file = File.expand_path(file)
    File.exist?(file) ? file : "#{file}.rb"
  end
end
