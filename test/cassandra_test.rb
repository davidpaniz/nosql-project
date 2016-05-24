require 'minitest/autorun'
require 'cassandra'

class TestCassandra < Minitest::Test
  def setup
    @keyspace  = 'ligado'
    @cassandra = Cassandra.cluster

    cria_keyspace(@cassandra)

    @ligado = @cassandra.connect @keyspace
    cria_tabelas(@ligado, @cassandra)
  end

  def test_cassandra_all
    result = @ligado.execute "SELECT COUNT(*) FROM musicas"
    assert_equal 0, result.rows.first['count']

    #insert
    insert = """INSERT INTO musicas (id, nome, album, artista)
                VALUES (a70ca7ff-6d57-4f89-be89-08421c432bb7, 'Help', 'Help', 'Beatles');"""
    @ligado.execute insert

    result = @ligado.execute "SELECT nome, album, artista FROM musicas"
    musica  = result.rows.first
    assert_equal "Help", musica['nome']
    assert_equal "Help", musica['album']
    assert_equal "Beatles", musica['artista']


    #update
    update = """UPDATE musicas SET nome='Help!', album='Help!'
                WHERE id = a70ca7ff-6d57-4f89-be89-08421c432bb7;"""
    @ligado.execute update

    result = @ligado.execute "SELECT nome, album, artista FROM musicas"
    musica  = result.rows.first
    assert_equal "Help!", musica['nome']
    assert_equal "Help!", musica['album']
    assert_equal "Beatles", musica['artista']


    #delete
    delete = """DELETE from musicas
                WHERE id = a70ca7ff-6d57-4f89-be89-08421c432bb7;"""
    @ligado.execute delete
    result = @ligado.execute "SELECT COUNT(*) FROM musicas"
    assert_equal 0, result.rows.first['count']

  end

  def cria_keyspace(client)
    keyspace_definition = <<-KEYSPACE_CQL
        CREATE KEYSPACE #{@keyspace}
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}
    KEYSPACE_CQL

    unless client.has_keyspace?(@keyspace)
      client.connect.execute(keyspace_definition)
      sleep 3 #FIXME remove sleep!!!
    end
    assert client.has_keyspace?(@keyspace)
  end


  def cria_tabelas(session, client)
    tabela_musica = <<-TABELA_MUSICA_CQL
      CREATE TABLE musicas (
        id uuid PRIMARY KEY,
        nome text,
        album text,
        artista text
      );
    TABELA_MUSICA_CQL

    tabela_playlist = <<-TABELA_PLAYLIST_CQL
      CREATE TABLE playlist_versionada (id_playlist uuid,
                                        versao int,
                                        modificacao text,
                                        PRIMARY KEY (id_playlist, versao)
                                     ) WITH COMPACT STORAGE;
    TABELA_PLAYLIST_CQL

    keyspace = client.keyspace(@keyspace)

    session.execute('DROP TABLE musicas') if keyspace.has_table?('musicas')
    session.execute(tabela_musica)

    session.execute('DROP TABLE playlist_versionada') if keyspace.has_table?('playlist_versionada')
    session.execute(tabela_playlist)
  end
end