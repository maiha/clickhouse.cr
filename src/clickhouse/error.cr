require "./error_code"

abstract class Clickhouse::Error < Exception
end

######################################################################
### Library Error

class Clickhouse::LibraryError < Clickhouse::Error
end

class Clickhouse::TypeNotSupported < Clickhouse::LibraryError
end

class Clickhouse::FieldNotFound < Clickhouse::LibraryError
end

class Clickhouse::DataNotFound < Clickhouse::LibraryError
end

class Clickhouse::CastError < Clickhouse::LibraryError
end

######################################################################
### Server Error

class Clickhouse::ServerError < Clickhouse::Error
  var uri  : URI
  var code : ErrorCode

  def self.parse(body : String)
    # "Code: 81, e.displayText() = DB::Exception: Database reports doesn't exist"
    case body
    when /\ACode:\s+(\d+).*?DB::Exception: (.*?),/
      return new($2).tap(&.code = ErrorCode.from_value?($1.to_i32))
    when /\ACode:\s+(\d+),\s*(.*)/
      return new($2).tap(&.code = ErrorCode.from_value?($1.to_i32))
    else
      return new(body)
    end
  end
end

class Clickhouse::ConnectionError < Clickhouse::ServerError
end

class Clickhouse::CannotConnectError < Clickhouse::ConnectionError
end

class Clickhouse::ConnectionLostError < Clickhouse::ConnectionError
end

class Clickhouse::CommandTimeoutError < Clickhouse::ServerError
end
