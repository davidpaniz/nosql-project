require './test/test_helper'

class TestRiak < Minitest::Test
  def setup
    @cassandra = Cassandra.cluster

    cria_keyspace(@cassandra)

    @ligado = @cassandra.connect 'ligado'
    cria_tabela_musica(@ligado, @cassandra)
  end

  def test_cassandra_all
    @ligado.execute "SELECT * FROM musicas"
    assert_equal 1, 1
  end


  def cria_keyspace(client)
    keyspace_definition = <<-KEYSPACE_CQL
        CREATE KEYSPACE ligado
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}
    KEYSPACE_CQL

    client.connect.execute(keyspace_definition) unless client.has_keyspace?('ligado')
  end


  def cria_tabela_musica(session, client)
    table_definition = <<-TABLE_CQL
      CREATE TABLE musicas (
        id uuid PRIMARY KEY,
        nome text,
        album text,
        artista text
      );
    TABLE_CQL

    keyspace = client.keyspace('ligado')
    session.execute('DROP TABLE musicas') if keyspace.has_table?('musicas')
    session.execute(table_definition)
  end
end