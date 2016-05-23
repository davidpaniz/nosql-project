require './test/test_helper'
require 'riak'

class TestRiak < Minitest::Test
  def setup
    @riak  = Riak::Client.new
    @votacao = @riak.bucket 'votacao'
  end

  def test_all
    voto = Riak::RObject.new(@votacao, "davidpaniz")
    voto.content_type = "text/plain"
    voto.raw_data = "Fulano"
    voto.store

    assert_equal "Fulano", @votacao.get("davidpaniz").raw_data
  end
end