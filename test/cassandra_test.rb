require './test/test_helper'
require 'cassandra'

class TestRiak < Minitest::Test
  def setup
    @cassandra = Cassandra.cluster
    session = @cassandra.connect
    keyspace_definition = <<-KEYSPACE_CQL
        CREATE KEYSPACE ligado
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}
    KEYSPACE_CQL

    table_definition = <<-TABLE_CQL
      CREATE TABLE musicas (
        id uuid PRIMARY KEY,
        nome text,
        album text,
        artista text
      );
    TABLE_CQL

    session.execute(keyspace_definition) unless @cassandra.has_keyspace?('ligado')

    keyspace = @cassandra.keyspace('ligado')
    @ligado = @cassandra.connect 'ligado'
    @ligado.execute('DROP TABLE musicas') if keyspace.has_table?('musicas')
    @ligado.execute(table_definition)
  end

  def test_all
    @ligado.execute "SELECT * FROM musicas"
  end
end