require "./spec_helper"

describe Clickhouse::Cast do
  it "works" do
    Clickhouse::Cast.cast(JSON::Any.new("a"), "String", "spec")
  end
end
