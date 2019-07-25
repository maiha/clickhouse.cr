class Clickhouse
  module QueryTokenizer
    enum Type
      EXACTLY
      INCLUDED
      MODIFIED
    end

    class Token
      def_equals positive, type, value, modifier?

      var positive : Bool
      var type     : Type
      var modifier : String
      var value    : String

      def initialize(@type, @value, @modifier)
        @positive = true
        case type
        when .modified?
          @modifier || raise "BUG: #{type} expects modifier, but not given"
        end
        @value || raise "BUG: #{type} expects value, but not given"
      end

      def not
        dup.tap{|t| t.positive = !t.positive}
      end

      def empty?
        value.size == 0
      end

      def to_s(io : IO)
        if !positive
          io << "-"
        end
        case type
        when .exactly?
          io << '"' << value << '"'
        when .included?
          io << value
        when .modified?
          io << modifier << ':' << value
        else
          io << value
        end
      end

      def inspect(io : IO)
        io << String.build do |s|
          s << "-" if !positive
          s << type.to_s.capitalize
        end
        io << '(' << '"' << value << '"' << ')'
      end
    end

    {% for c in Type.constants %}
      def Token.{{c.downcase}}(value, modifier = nil) : Token
        Token.new(Type::{{c}}, value, modifier)
      end
    {% end %}

    def self.tokenize(s : String) : Array(Token)
      s = s.strip
      case s
      when /\A\s*\Z/
        return Array(Token).new
      when /(\A|\s)-"(.*?)"/
        ary = tokenize($~.pre_match) + [Token.exactly($2).not] + tokenize($~.post_match)
      when /(\A|\s)"(.*?)"/
        ary = tokenize($~.pre_match) + [Token.exactly($2)] + tokenize($~.post_match)
      when /\s/
        ary = s.split(/\s+/).map{|i| tokenize(i)}.flatten
      when /\A-(.*?):(.*?)\Z/
        ary = [Token.modified($2, $1).not]
      when /\A(.*?):(.*?)\Z/
        ary = [Token.modified($2, $1)]
      when /\A-(.*?)\Z/
        ary = [Token.included($1).not]
      else
        ary = [Token.included(s)]
      end

      return ary.reject(&.empty?)
    end
  end
end
