CREATE TABLE backquote (
  `d` Date,
  `k` UInt64
)
ENGINE = MergeTree(d, k, 8192)
