require './test/test_helper'
require 'mongo'

class TestMongo < Minitest::Test
  def setup
    @mongo = Mongo::Client.new([ @@host ], :database => "ligato")
    @albuns = @mongo[:albuns]

    @albuns.delete_many({})
  end

  def test_all
    assert_equal 0, @albuns.count
    @albuns.insert_one({})
    assert_equal 1, @albuns.count
  

    @albuns.insert_one({"nome"            => "Master of Puppets",
                        "dataLancamento"  => Date.new(1986, 2, 3),
                        "duracao"         => 3286})

	@albuns.insert_one({"nome"            => "...And Justice for All",
                        "dataLancamento"  => Date.new(1988, 7, 25),
                        "duracao"         => 3929})

	@albuns.insert_one({"nome"            => "Peace Sells... but Who's Buying?",
                        "duracao"         => 2172,
                        "estudioGravacao" => "Music Grinder Studios",
                        "dataLancamento"  => Date.new(1986, 8, 19)})

	@albuns.insert_one({"nome"            => "Reign in Blood",
                        "dataLancamento"  => Date.new(1986, 9, 7),
                        "artistaCapa"     => "Larry Carroll",
                        "duracao"         => 1738})

	@albuns.insert_one({"nome"            => "Among the Living",
                        "produtor"        => "Eddie Kramer"})

    assert_equal 6, @albuns.count


    query = @albuns.find('nome' => "Master of Puppets")

    total = query.count
    album = query.first

	assert_equal 1, total
	assert_equal album['duracao'], 3286
  end

end