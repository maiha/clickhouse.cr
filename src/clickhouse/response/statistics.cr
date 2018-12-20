struct Clickhouse::Response::Statistics
  Jq.mapping({
    elapsed: Float64,  # 0.000671276
    rows_read: Int64,  # 1
    bytes_read: Int64, # 1
  })
end      
