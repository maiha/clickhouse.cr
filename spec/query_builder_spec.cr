require "./spec_helper"

describe Clickhouse::QueryBuilder do
  it "#contains" do
    qb = Clickhouse::QueryBuilder.new
    qb.contains("name", "foo")
    qb.where.should eq "(positionCaseInsensitiveUTF8(name, 'foo') > 0)"
  end

  it "#contains(not: true)" do
    qb = Clickhouse::QueryBuilder.new
    qb.contains("name", "foo", not: true)
    qb.where.should eq "(positionCaseInsensitiveUTF8(name, 'foo') = 0)"
  end

  it "#by_name" do
    qb = Clickhouse::QueryBuilder.new
    qb.by_name("foo")
    qb.where.should eq ""

    qb.name_fields << "name"
    qb.by_name("foo")
    qb.where.should eq  "(positionCaseInsensitiveUTF8(concat(name), 'foo') > 0)"
  end


  it "#by_name(not: true)" do
    qb = Clickhouse::QueryBuilder.new
    qb.by_name("foo", not: true)
    qb.where.should eq ""

    qb.name_fields << "name"
    qb.by_name("foo", not: true)
    qb.where.should eq  "(positionCaseInsensitiveUTF8(concat(name), 'foo') = 0)"
  end

end
