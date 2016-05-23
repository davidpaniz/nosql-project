require './test/test_helper'
require 'riak'

class TestRiak < Minitest::Test
  def setup
    @riak  = Riak::Client.new()
    @votacao = @riak.bucket "votacao#{rand()}"
  end

  def cria_riak_object(chave, valor)
    voto = Riak::RObject.new(@votacao, chave)
    voto.content_type = "text/plain"
    voto.raw_data = valor
    voto
  end

  def test_all
    assert_equal [], @riak.list_keys(@votacao)

    #adiciona primeiro voto
    voto = cria_riak_object "davidpaniz", "Fulano"
    voto.store
    assert_equal "Fulano", @votacao.get("davidpaniz").data

    assert_equal ["davidpaniz"], @riak.list_keys(@votacao)

    # adiciona segundo voto
    voto = cria_riak_object "adriano", "Ciclano"
    voto.store
    assert_equal "Ciclano", @votacao.get("adriano").data

    assert_includes @riak.list_keys(@votacao), "adriano", "davidpaniz"

    #removendo primeiro voto
    @votacao.delete("davidpaniz")
    refute @votacao.exists?("davidpaniz")
  end
end