# clickhouse.cr

ClickHouse client for [Crystal](http://crystal-lang.org/).

* **tested crystal versions** : See [ci](./ci)

## Usage

`Clickhouse#execute` returns a `Clickhouse::Response` which includes `Enumerable(Array(Type))`.

```crystal
require "clickhouse"

client = Clickhouse.new(host: "localhost", port: 8123)

res = client.execute <<-SQL
  SELECT   database, count(*)
  FROM     system.tables
  GROUP BY database
  SQL

res.rows    # => 2
res.to_a    # => [["system", 35], ["test", 9], ...

res.map(String, UInt64).each do |(name, cnt)|
  p [name, cnt]

client.databases # => ["default", "system", ...
```

## API

```crystal
Clickhouse
  def self.new(host = "localhost", port = 8123, database = nil, ...)
  def execute(sql : String) : Response
  # reflection
  def databases : Array(Database)
  def database(name : String) : Database
  def tables(database : String) : Array(Table)
  def table(database : String, name : String) : Table

Clickhouse::Response
  def each
  def each_hash
  def records : Array(Record)
  def map(*types : *T) forall T
  def map(**types : **T) forall T
  def success? : Response?
  def success! : Response
  def to_json : String

Clickhouse::Database
  def name : String
  def tables : Array(Table)

Clickhouse::Table
  def name : String
  def columns : Array(Column)
  def count : UInt64

Clickhouse::Column
  def name : String
  def type : String
```

## Response

### records

```crystal
res.each do |ary|
  ary.class        # => Array(Clickhouse::Type)
  ary[0]           # => "system"
  ary[1]           # => 35

res.each_hash do |hash|
  hash.class       # => Hash(String, Clickhouse::Type))
  hash["database"] # => "system"
  hash["count(*)"] # => 35

res.records.each do |hash|
  hash.class       # => Hash(String, Clickhouse::Type))
  hash["database"] # => "system"
  hash["count(*)"] # => 35

res.map(String, UInt64).each do |(name, cnt)|
  name.class       # => String
  name             # => "system"
  cnt              # => 35

res.map(name: String, cnt: UInt64).each do |r|
  r.class          # => NamedTuple(name: String, cnt: UInt64)
  r["name"]        # => "system"
  r["cnt"]         # => 35
```

### statistics

```crystal
res.statistics.elapsed    # => 0.000671276
res.statistics.rows_read  # => 1
res.statistics.bytes_read # => 1
```

## Supported Data types

- [x] Array(T)
- [x] Nullable(T)
- [x] Boolean (as UInt8)
- [x] Date
- [x] DateTime
  - [ ] Time zones
- [ ] Enum
- [ ] FixedString(N)
- [x] Float32, Float64
- [x] UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32, Int64
  - [ ] Int ranges
  - [ ] Uint ranges
- [x] String
- [ ] Tuple(T1, T2, ...)
- [ ] Nested data structures
- [ ] Special data types

See [src/clickhouse/cast.cr](./src/clickhouse/cast.cr) for more details

## Schema

provides reflecting database objects.

- [Database](./src/clickhouse/database.cr)
- [Table](./src/clickhouse/table.cr)
- [Column](./src/clickhouse/column.cr)

```crystal
client = Clickhouse.new
client.databases.map(&.name)
# => ["default", "system", ...

system = client.database("system")
system.tables.map(&.name)
# => ["aggregate_function_combinators", "asynchronous_metrics", ...

table = client.table("system", "parts")
table.columns.map(&.name)
# => ["partition", "name", ...

table.columns.select(&.type.=~(/DateTime/)).map(&.name)
# => ["modification_time", "remove_time", "min_time", "max_time"]
```

## Create Schema

```crystal
buf = <<-SQL
  CREATE TABLE logs (
    `d` Date,
    `k` UInt64
  )
  ENGINE = MergeTree(d, k, 8192)
  SQL

create = Clickhouse::Schema::Create.parse(buf)
create.table            # => "logs"
create.column("d").type # => "Date"
create.engine           # => "MergeTree(d, k, 8192)"
create.to_sql           # should be `buf`
```

## Migrate Plans

```crystal
migrate = Migrate.new(columns1, columns2)
migrate.plans.size  # => 4
migrate.map(&.name) # => ["id", "age", "hobby"]

puts migrate.manifest
# 1  id     MODIFY COLUMN `id` Int64
# 2  name   # NOP
# 3  age    DROP COLUMN `age`
# 4  hobby  ADD COLUMN `hobby` String
```

## QueryTokenizer

This provides general purpose query tokenizer like well-known advanced search.

```crystal
string = %( foo from:user1 "a:b" -bar -"-x:-y" )
tokens = Clickhouse::QueryTokenizer.tokenize(string)

puts tokens.map(&.inspect)
# [Included("foo"), Modified("user1"), Exactly("a:b"), -Included("bar"), -Exactly("-x:-y")]
puts tokens.map(&.to_s)
 # ["foo", "from:user1", "\"a:b\"", "-bar", "-\"-x:-y\""]
```

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  var:
    github: maiha/clickhouse.cr
    version: 1.0.0
```
2. Run `shards install`

## Development

```shell
make test
```

### Add a new DataType

1. [src/clickhouse/data_type.cr](./src/clickhouse/data_type.cr) Define ClickHouse DataType
2. [src/clickhouse.cr](./src/clickhouse.cr) Add corresponding Crystal class into `Clickhouse::Type`
3. [src/clickhouse/cast.cr](./src/clickhouse/cast.cr) Add logic to combine them

## Roadmap

- Core
  - [x] all primitive DataType
- Request
  - [ ] output format
- Response
  - [x] statistics methods
  - [ ] fetch value by field name

#### BREAKING CHANGES
- 0.3.0: `Column#type` is now `String` because `enum` can't handle `Array(Int32)` as its value.

## Contributing

1. Fork it (<https://github.com/maiha/clickhouse.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
