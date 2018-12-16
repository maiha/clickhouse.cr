record Clickhouse::Response,
  req  : Request,
  http : HTTP::Client::Response,
  time : Time::Span

require "./response/**"

struct Clickhouse::Response
  include Enumerable(Array(Type))

  var parsed : JSONCompactParser = JSONCompactParser.parse(body)
  var meta   : Array(JSONCompactParser::Field) = parsed.meta
  var data   : Array(Array(JSON::Any)) = parsed.data

  delegate status_code, success?, body, to: http

  def fields; meta; end

  def each
    data.each do |row|
      vals = row.map_with_index{|any, i|
        field = fields[i]? || raise FieldNotFound.new("no field[#{i}] in #{meta}")
        cast(any, field)
      }
      yield vals
    end
  end

  def to_json : String
    case req.format
    when OutputFormat::JSONCompact
      JSONCompactParser.data(body)
    else
      body
    end
  end

  protected def cast(any : JSON::Any, field : JSONCompactParser::Field) : Type
    Cast.cast(any, field.data_type)
  end
end
