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

  describe "#by_name" do
    context "(with one field)" do
      it "uses the field itself" do
        qb = Clickhouse::QueryBuilder.new
        qb.by_name("foo")
        qb.where.should eq ""

        qb.name_fields << "name"
        qb.by_name("foo")
        qb.where.should eq  "(positionCaseInsensitiveUTF8(name, 'foo') > 0)"
      end
    end

    context "(with two fields)" do
      it "uses concatinated fields" do
        qb = Clickhouse::QueryBuilder.new
        qb.by_name("foo")
        qb.where.should eq ""

        qb.name_fields << "name"
        qb.name_fields << "campaign_name"
        qb.by_name("foo")
        qb.where.should eq  "(positionCaseInsensitiveUTF8(concat(name,campaign_name), 'foo') > 0)"
      end
    end
  end

  describe "#by_name(not: true)" do
    context "(with one field)" do
      it "uses the field itself" do
        qb = Clickhouse::QueryBuilder.new
        qb.by_name("foo", not: true)
        qb.where.should eq ""

        qb.name_fields << "name"
        qb.by_name("foo", not: true)
        qb.where.should eq  "(positionCaseInsensitiveUTF8(name, 'foo') = 0)"
      end
    end

    context "(with two fields)" do
      it "uses the field itself" do
        qb = Clickhouse::QueryBuilder.new
        qb.by_name("foo", not: true)
        qb.where.should eq ""

        qb.name_fields << "name"
        qb.name_fields << "campaign_name"
        qb.by_name("foo", not: true)
        qb.where.should eq  "(positionCaseInsensitiveUTF8(concat(name,campaign_name), 'foo') = 0)"
      end
    end
  end
end
