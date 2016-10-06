

module SpyGenerator

  module ParseUtil

    def extract_block(text, start_line_matcher, escape: false)
      start_line_matcher = Regexp.escape(start_line_matcher) if escape

      start_line = text[/^.*#{start_line_matcher}.*/]
      return unless start_line

      indent = start_line[/\s*/]
      escaped = Regexp.escape(start_line)
      text[/#{escaped}.*?^#{indent}\}/m] 
    end
  end

  class ClassParser
    include ParseUtil

    def initialize
      @source_files = Dir.glob File.join(__dir__, "{Model,Scene}/**/*.swift")
    end

    def find_class(class_name)
      @source_files.each do |file|
        source = File.read(file)
        if class_definition = extract_class(class_name, source)
          return SwiftClass.new(class_definition)
        end
      end
    end

    def extract_class(class_name, text)
      extract_block(text, "class #{class_name}", escape: true)
    end

    class SwiftClass

      attr_reader :class_signature, :func_signatures

      def initialize(text)
        @class_signature = text[/(^.+)\{/, 1].rstrip
        @func_signatures = text.scan(/(^.*func.+){/).map { |m| m.first.lstrip.rstrip }

        decorate
      end

      def decorate
        @class_signature.define_singleton_method(:name) { self[/class\s(\w+)/, 1] }

        @func_signatures.each do |f|
          f.define_singleton_method(:short_name)  { self[/func\s(\w+)/, 1] }
          f.define_singleton_method(:full_name)   { self[/func\s(.+)/, 1] }
          f.define_singleton_method(:return_type) { self[/->\s(\w+)/, 1] }
          f.define_singleton_method(:params)      { self[/\((.+?)\)/, 1] }
        end
      end
    end
  end


  module CodeGenerator; class << self

    def generate(swift_class)
      c = swift_class
"class Spy#{c.class_signature.name} : #{c.class_signature.name} {
  #{
    c.func_signatures.map { |f| gen_variable(f) }.join("\n  ")
  }

  #{
    c.func_signatures.map { |f| gen_func(f) }.join("\n\n  ")
  }
}"
    end

    def gen_variable(func)
      "var called_" + func.short_name + ": Bool = false"
    end

    def gen_func(func)
      code =
  "override func #{func.full_name} {
    called_#{func.short_name} = true
    #{gen_return(func)}
  }"

      code.lines.reject { |l| l =~ /^\s*$/ }.join("")  # remove blank lines
    end

    def gen_return(func)
      return "" unless func.return_type
      return return_with_params(func, "") unless func.params

      params = func.params.split(",").map { |p| p.split(":").first.split(" ") }

      ret = params.reduce("") do |acc, p|
        if p.size == 2
          acc + (p.first == "_" ? "#{p.last}, " : "#{p.first}: #{p.last}, ")
        else
          acc + "#{p.first}: #{p.first}, "
        end
      end

      return_with_params(func, ret[0...-2])
    end

    def return_with_params(func, params)
      "return super." + func.short_name + "(#{params})"
    end
  end; end
end


if ARGV.empty?
  puts "Usage: ruby spy_generator.rb SWIFT_CLASS"
  exit
end

parser = SpyGenerator::ClassParser.new
c = parser.find_class(ARGV.first)

code = SpyGenerator::CodeGenerator.generate(c)

File.open(File.join(__dir__, "SceneTests/Common.swift"), "a") do |f|
  f.puts "\n\n" + code
end

puts "ok"
