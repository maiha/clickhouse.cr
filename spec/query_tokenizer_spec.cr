require "./spec_helper"

macro tokenize(src, dst)
  it "decode: " + {{src.stringify}} do
    Clickhouse::QueryTokenizer.tokenize({{src}}).should eq({{dst}})
  end

  it "encode: " + {{src.stringify}} do
    tokens = Clickhouse::QueryTokenizer.tokenize({{src}})
    tokens.map(&.to_s).join(" ").should eq({{src}}.strip)
  end
end    

class Clickhouse::QueryTokenizer::Token

  describe ".tokenize" do
    # single word
    tokenize %(foo)         , [included("foo")]
    tokenize %(-zzz)        , [included("zzz").not]
    tokenize %(from:user1)  , [modified("user1", "from")]
    tokenize %(-from:user1) , [modified("user1", "from").not]
    tokenize %("-zzz")      , [exactly("-zzz")]
    tokenize %(-"zzz")      , [exactly("zzz").not]
    tokenize %("from:user1"), [exactly("from:user1")]
    tokenize %(fo"o)        , [included(%(fo"o))]

    # plural words
    tokenize %( foo )    , [included("foo")]
    tokenize %( foo bar ), [included("foo"), included("bar")]
    tokenize %(foo from:user1 "a:b" -bar -"-x:-y" ),
             [included("foo"), modified("user1", "from"), exactly("a:b"), included("bar").not, exactly("-x:-y").not]

    it "works as in README" do
      string = %( foo from:user1 "a:b" -bar -"-x:-y" )
      tokens = Clickhouse::QueryTokenizer.tokenize(string)

      tokens.map(&.inspect).join(", ").should eq(%(Included("foo"), Modified("user1"), Exactly("a:b"), -Included("bar"), -Exactly("-x:-y")))
      tokens.map(&.to_s).join(", ").should eq(%(foo, from:user1, "a:b", -bar, -\"-x:-y"))
    end
  end

end
