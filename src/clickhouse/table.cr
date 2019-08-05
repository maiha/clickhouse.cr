require "./column"

class Clickhouse::Table
  getter name
  delegate ctx, to: @database

  def initialize(@database : Database, @name : String)
  end

  def columns # : Array(String) # Array(Column)
    sql = "SELECT * FROM %s.%s LIMIT 0 FORMAT JSONCompact" % [@database.name, @name]
    req = Request.new(sql, OutputFormat::JSONCompact)
    res = ctx.execute(req)
    meta = Response::JSONCompactParser.parse(res.success!.body).meta
    meta.map{|field| Column.new(field.name, field.type)}
    #    return names.map
  end

  def to_s(io : IO)
    io << @name
  end

  def inspect(io : IO)
    io << "Table(%s, %s)" % [@name.inspect, @ctx ? "active" : "lost"]
  end
end
