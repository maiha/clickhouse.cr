class Clickhouse::Column
  var name : String
  var type : DataType

  def self.new(name : String, type : String)
    new(name, DataType.parse(type))
  end

  def initialize(@name, @type)
  end

  def to_s(io : IO)
    io << name << " " << type.to_s
  end
end
