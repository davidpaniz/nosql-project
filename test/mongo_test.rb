require 'minitest/autorun'
require 'mongo'

class TestMongo < Minitest::Test
  def setup
    Mongo::Logger.logger.level = ::Logger::ERROR
    @mongo  = Mongo::Client.new(['localhost'], :database => "ligato")
    @albuns = @mongo[:albuns]

    @albuns.delete_many({})
  end

  def test_mongo_all
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

    # remove
    query = @albuns.find("nome" => "...And Justice for All")
    assert_equal 1, query.count
    query.delete_one #equivalente a albuns.remove({"nome": "...And Justice for All"}, {justOne: true})
    assert_equal 0, query.count


    #udpate
    album_antes = @albuns.find("nome" => "Among the Living").first
    @albuns.update_one({"nome" => "Among the Living"}, {"duracao" => 3013})
    album_depois = @albuns.find("_id" => album_antes['_id']).first
    # O update sobrescreve o documento inteiro, apagando as chaves
    refute_equal album_antes['nome'], album_depois['nome']
    #update usando $set
    @albuns.update_one({"_id" => album_antes['_id']}, {"$set" => {"nome" => "Among the Living",
                                                                  "produtor" => "Eddie Kramer"}})

    album_final = @albuns.find("nome" => "Among the Living").first
    assert_equal "Among the Living", album_final['nome']
    assert_equal 3013, album_final['duracao']
  end
end