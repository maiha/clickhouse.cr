CREATE TABLE campaign (
  id String,
  name String,
  start_time String,
  end_time String,
  duration_in_days Nullable(Int64),
  standard_delivery UInt8,
  servable UInt8,
  funding_instrument_id String,
  daily_budget_amount_local_micro Nullable(Int64),
  total_budget_amount_local_micro Nullable(Int64),
  reasons_not_servable Array(String),
  frequency_cap Nullable(Int64),
  currency String,
  created_at String,
  updated_at String,
  entity_status String,
  deleted UInt8,
  account_id String
)
ENGINE = Log
