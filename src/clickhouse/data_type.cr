# Entries are manually maintained by checking official document.
# https://clickhouse-docs.readthedocs.io/en/latest/data_types/

enum Clickhouse::DataType
  # Array(T)
  Boolean
  Date
  DateTime
  # Enum
  # FixedString(N)
  Float32
  Float64
  UInt8
  UInt16
  UInt32
  UInt64
  Int8
  Int16
  Int32
  Int64
  # Int ranges
  # Uint ranges
  String
  # Tuple(T1, T2, ...)
  # Nested data structures
  # AggregateFunction(name, types_of_arguments...)
  # Nested(Name1 Type1, Name2 Type2, ...)
  # Special data types
  # Expression
  # Set
end    
