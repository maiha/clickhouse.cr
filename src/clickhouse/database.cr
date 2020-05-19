require "./table"

class Clickhouse::Database
  getter name

  def initialize(@name : String, @ctx : Clickhouse?= nil)
  end

  def tables : Array(Table)
    sql = "SELECT name FROM system.tables WHERE database='%s'" % @name
    names = ctx.execute_as_csv(sql).flatten.sort
    return names.map{|name| Table.new(self, name)}
  end

  def ctx
    @ctx || raise "no active connections"
  end

  def ctx?
    @ctx
  end

  def to_s(io : IO)
    io << @name
  end
  
  def inspect(io : IO)
    io << "Database(%s, %s)" % [@name.inspect, @ctx ? "active" : "lost"]
  end
end
