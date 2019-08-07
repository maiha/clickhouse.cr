class Clickhouse::Response::JSONCompactParser
  include Enumerable(Array(Type))

  Jq.mapping({
    meta: Array(Field),
    data: Array(Array(JSON::Any)),
    rows: Int64,
    statistics: Statistics,
  })

  def field(i : Int32)
    meta[i]? || raise FieldNotFound.new("no field[#{i}] in #{meta}")
  end

  def each
    data.each_with_index do |row, i|
      vals = row.map_with_index{|any, j|
        field = field(j)
        hint  = "data[#{i}][#{j}](#{field})"
        cast(any, field, hint)
      }
      yield vals
    end
  end

  def scalar
    each do |row|
      if row.size > 0
        return row.first
      else
        raise DataNotFound.new("data[0][0]")
      end
    end
    raise DataNotFound.new("data[0]")
  end

  protected def cast(any : JSON::Any, field : Field, hint : String)
    Cast.cast(any, field.type, hint)
  end
end

class Clickhouse::Response::JSONCompactParser
  def self.parse(body : String)
    from_json(body)
  end

  def self.data(body : String) : String
    Jq.new(body)[".data"].any.to_json
  end
end
