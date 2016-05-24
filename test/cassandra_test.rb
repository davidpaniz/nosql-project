require 'minitest/autorun'
require 'cassandra'

class TestCassandra < Minitest::Test
  def setup
    @keyspace = 'ligado'
    @cassandra = Cassandra.cluster

    cria_keyspace(@cassandra)

    @ligado = @cassandra.connect @keyspace
    cria_tabela_musica(@ligado, @cassandra)
  end

  def test_cassandra_all
    @ligado.execute "SELECT * FROM musicas"
    assert_equal 1, 1
  end


  def cria_keyspace(client)
    keyspace_definition = <<-KEYSPACE_CQL
        CREATE KEYSPACE #{@keyspace}
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}
    KEYSPACE_CQL

    client.connect.execute(keyspace_definition) unless client.has_keyspace?(@keyspace)
    sleep 3 #FIXME remove sleep!!!
    assert client.has_keyspace?(@keyspace)
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

    keyspace = client.keyspace(@keyspace)
    session.execute('DROP TABLE musicas') if keyspace.has_table?('musicas')
    session.execute(table_definition)
  end
end