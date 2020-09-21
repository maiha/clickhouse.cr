class Clickhouse::Migrate
  enum Type
    NOP
    ADD
    DROP
    MODIFY
    ERROR
  end
end
