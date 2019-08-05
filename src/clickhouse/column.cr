class Clickhouse::Column
  var name : String
  var type : String

  def initialize(@name, @type)
  end

  def to_s(io : IO)
    io << name << " " << type.to_s
  end
end
