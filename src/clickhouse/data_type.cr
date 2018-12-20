# Entries are manually maintained by checking official document.
# https://clickhouse-docs.readthedocs.io/en/latest/data_types/

enum Clickhouse::DataType
  Boolean
  Date
  DateTime
  FixedString
  Float32
  Float64
  Int8
  Int16
  Int32
  Int64
  String
  UInt8
  UInt16
  UInt32
  UInt64
end
