require 'minitest/autorun'
require 'neo4j-core'

class TestNeo4j < Minitest::Test
  def setup
    @neo = Neo4j::Session.open(:server_db, 'http://neo4j:password@localhost:7474')
  end

  def test_neo4j_all
    assert_equal 1, 1
  end
end