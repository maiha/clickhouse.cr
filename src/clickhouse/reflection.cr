module Clickhouse::Reflection
  def databases : Array(Database)
    sql = "SHOW DATABASES"
    names = execute_as_csv(sql).flatten.sort
    return names.map{|name| database(name)}
  end

  def database(name : String) : Database
    Database.new(name, self)
  end

  def tables(database : String) : Array(Table)
    self.database(database).tables
  end

  def table(database : String, name : String) : Table
    db = self.database(database)
    Table.new(db, name)
  end
end
