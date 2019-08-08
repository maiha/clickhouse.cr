module Clickhouse::Schema
  IDENTIFIER = "[a-zA-Z][a-zA-Z0-9_]*"
  TYPE_IDENTIFIER = "[A-Z][a-zA-Z0-9]*(\\([A-Z][a-zA-Z0-9]*\\))?"
end

require "./schema/**"
