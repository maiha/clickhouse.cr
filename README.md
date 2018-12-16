# clickhouse.cr [![Build Status](https://travis-ci.org/maiha/clickhouse.cr.svg?branch=master)](https://travis-ci.org/maiha/clickhouse.cr)

ClickHouse client for Crystal

## Usage

`Clickhouse#execute` returns a `Clickhouse::Response` which includes `Enumerable(Array(Type))`.

```crystal
require "clickhouse"

client = Clickhouse.new(host: "localhost", port: 8123)

res = client.execute("SELECT 1, 'foo'")
res.size # => 1
res.to_a # => [[1, "foo"]]
res.each do |vals|
  vals   # => [1, "foo"]
end
```

## Available DataType

- ClickHouse : [src/clickhouse/data_type.cr](./src/clickhouse/data_type.cr) 

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  var:
    github: maiha/clickhouse.cr
    version: 0.1.0
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

## TODO

- Core
  - [ ] Support all primitive DataType
- Request
  - [ ] output format
- Response
  - [ ] statistics methods
  - [ ] fetch value by field name

## Contributing

1. Fork it (<https://github.com/maiha/clickhouse.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
