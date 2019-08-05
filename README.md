# clickhouse.cr [![Build Status](https://travis-ci.org/maiha/clickhouse.cr.svg?branch=master)](https://travis-ci.org/maiha/clickhouse.cr)

ClickHouse client for [Crystal](http://crystal-lang.org/).

- crystal: 0.30.0

## Usage

`Clickhouse#execute` returns a `Clickhouse::Response` which includes `Enumerable(Array(Type))`.

```crystal
require "clickhouse"

client = Clickhouse.new(host: "localhost", port: 8123)

res = client.execute("SELECT 'foo', 2")
res.to_a                  # => [["foo", 2]]
res.rows                  # => 1
res.statistics.elapsed    # => 0.000671276
res.statistics.rows_read  # => 1
res.statistics.bytes_read # => 1
res.scalar                # => "foo"
```

## Available DataType

- ClickHouse : [src/clickhouse/data_type.cr](./src/clickhouse/data_type.cr) 

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

table.columns.select(&.type.date_time?).map(&.name)
# => ["modification_time", "remove_time", "min_time", "max_time"]
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
    version: 0.3.0
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
