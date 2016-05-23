require './test/test_helper'
require 'mongo'

class TestMongo < Minitest::Test
  def setup
    @mongo  = Mongo::Client.new([@@host], :database => "ligato")
    @albuns = @mongo[:albuns]

    @albuns.delete_many({})
  end

  def test_all
    assert_equal 0, @albuns.count
    @albuns.insert_one({})
    assert_equal 1, @albuns.count


    @albuns.insert_one({ "nome"           => "Master of Puppets",
                         "dataLancamento" => Date.new(1986, 2, 3),
                         "duracao"        => 3286 })

    @albuns.insert_one({ "nome"           => "...And Justice for All",
                         "dataLancamento" => Date.new(1988, 7, 25),
                         "duracao"        => 3929 })

    @albuns.insert_one({ "nome"            => "Peace Sells... but Who's Buying?",
                         "duracao"         => 2172,
                         "estudioGravacao" => "Music Grinder Studios",
                         "dataLancamento"  => Date.new(1986, 8, 19) })

    @albuns.insert_one({ "nome"           => "Reign in Blood",
                         "dataLancamento" => Date.new(1986, 9, 7),
                         "artistaCapa"    => "Larry Carroll",
                         "duracao"        => 1738 })

    @albuns.insert_one({ "nome"     => "Among the Living",
                         "produtor" => "Eddie Kramer" })

    assert_equal 6, @albuns.count

    # find encontrando 1 álbum
    query = @albuns.find('nome' => "Master of Puppets")

    total = query.count
    album = query.first

    assert_equal 1, total
    assert_equal album['duracao'], 3286


    # find sem encontrar nada
    query = @albuns.find('nome' => "zzzz")
    total = query.count
    assert_equal 0, total

    # find usando $lt
    query = @albuns.find("duracao" => { "$lt" => 1800 })
    total = query.count
    album = query.first

    assert_equal 1, total
    assert_equal album['nome'], "Reign in Blood"

    # find usando $and
    query = @albuns.find("$and" => [{"dataLancamento" => {"$gte" => Date.new(1986, 1, 1)}},
                                    {"dataLancamento" => {"$lt" =>  Date.new(1987, 1, 1)}}])
    total = query.count
    nome_albuns = query.map {|album| album['nome']}

    assert_equal 3, total
    assert_equal nome_albuns, ["Master of Puppets", "Peace Sells... but Who's Buying?", "Reign in Blood"]

    # find com 2 critérios no mesmo campo
    query = @albuns.find("dataLancamento" => {"$gte" => Date.new(1986, 1, 1),
                                              "$lt" =>  Date.new(1987, 1, 1)})
    total = query.count
    nome_albuns = query.map {|album| album['nome']}

    assert_equal 3, total
    assert_equal nome_albuns, ["Master of Puppets", "Peace Sells... but Who's Buying?", "Reign in Blood"]
  end
end