class Clickhouse::Schema::Create
  def self.mock(name : String)
    path = File.join(__DIR__, "meta/#{name}")
    parse(File.read(path))
  end
end
