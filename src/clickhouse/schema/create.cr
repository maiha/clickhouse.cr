class Clickhouse::Schema::Create
  var create  : String = "CREATE TABLE"
  var db      : String
  var table   : String
  var column  : String
  var columns : Array(Column) = self.class.parse_columns(column)
  var engine  : String

  def to_sql
    String.build do |io|
      io << create << " " << db << "." << table << " (\n"
      columns.each_with_index do |column, i|
        io << "  " << column.name << " " << column.type.to_s
        io << "," if i < columns.size - 1
        io.puts
      end
      io.puts ")"
      io << "ENGINE = " << engine
    end
  end

  def to_s(io : IO)
    io << to_sql
  end
end

class Clickhouse::Schema::Create
  def self.parse(buf : String) : Create
    schema = new
    case buf
    when /\A\s*(?<create>(CREATE|ATTACH)\s+TABLE(\s+IF\s+NOT\s+EXISTS)?)\s+(?:(?<db>#{IDENTIFIER})\.)?(?<table>#{IDENTIFIER})\s*\((?<column>.*?)\)\s*ENGINE\s*=\s*(?<engine>.*)(?:;|\Z)/im
      schema.create = $~["create"]?
      schema.db     = $~["db"]?
      schema.table  = $~["table"]
      schema.column = $~["column"].strip
      schema.engine = $~["engine"].strip
    else
      raise "can't parse create schema from: #{buf}"
    end
    return schema
  end

  def self.parse_columns(buf : String) : Array(Column)
    array = Array(Column).new
    buf.split(/,/).each do |line|
      case line
      when /\A\s*(#{IDENTIFIER})\s+(#{IDENTIFIER})\s*\Z/m
        array << Column.new($1, DataType.parse($2))
      else
        raise "can't parse schema column: #{line}"
      end
    end
    return array
  end
end
