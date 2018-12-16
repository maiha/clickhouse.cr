# ```console
# git grep 'registerOutputFormat("' | grep -oP '(?<=").+(?=")' | sort
# ```

enum Clickhouse::OutputFormat
  JSON
  JSONCompact
  JSONEachRow
  Native
  Null
  ODBCDriver
  Pretty
  PrettyCompact
  PrettyCompactMonoBlock
  PrettyCompactNoEscapes
  PrettyNoEscapes
  PrettySpace
  PrettySpaceNoEscapes
  RowBinary
  TSKV
  Values
  Vertical
  XML
end
