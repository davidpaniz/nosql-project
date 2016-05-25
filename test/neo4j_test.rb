require 'minitest/autorun'
require 'neo4j-core'

class TestNeo4j < Minitest::Test
  def setup
    @neo = Neo4j::Session.open(:server_db, 'http://neo4j:password@localhost:7474')
    flush_db
  end

  def test_neo4j_all
    #create
    assert_equal 0, @neo.query("""MATCH (m:Musico) RETURN count(m) AS total""").first.total

    @neo.query("CREATE(dylan:Musico {nome : 'Bob Dylan', data_de_nascimento : '1941-05-24'})")
    bob = @neo.query("""MATCH (m:Musico) RETURN m.nome AS nome""").first
    assert_equal 'Bob Dylan', bob.nome

    # carregar_musicos_e_musicas
  end


  def carregar_musicos_e_musicas
    interpretes = [["Jimi Hendrix", "All Along the Watchtower"],
                   ["Johnny Cash", "It Ain't Me, Babe"],
                   ["Jack White", "One More Cup of Coffee"],
                   ["George Harrison", "If Not For You"],
                   ["Joey Ramone", "My Back Pages"],
                   ["Jon Bon Jovi", "Knockin' on Heavens"],
                   ["Steve Tyler", "Crazy"],
                   ["Ricky Martin", "Livin' la Vida Loca"],
                   ["Jon Bon Jovi", "Livin' on a Prayer"],
                   ["Jon Bon Jovi", "You Give Love a Bad Name"]]

    compositores = [["Bob Dylan", "All Along the Watchtower"],
                    ["Bob Dylan", "It Ain't Me, Babe"],
                    ["Bob Dylan", "One More Cup of Coffee"],
                    ["Bob Dylan", "If Not For You"],
                    ["Bob Dylan", "My Back Pages"],
                    ["Bob Dylan", "Knockin' on Heavens"],
                    ["Desmond Child", "Crazy"],
                    ["Desmond Child", "Livin' la Vida Loca"],
                    ["Desmond Child", "Livin' on a Prayer"],
                    ["Desmond Child", "You Give Love a Bad Name"]]

    compositores.each { |musico, musica|
      manipula_composicao(musico, musica)
    }

    interpretes.each { |musico, musica|
      manipula_gravacao(musico, musica)
    }
  end

  def flush_db
    @neo.query("""MATCH (n)
                  OPTIONAL MATCH (n)-[rel]-()
                  DELETE rel, n""")
  end

  def manipula_composicao(musico, musica)
    query = """MERGE (interprete:Musico {nome: {musico}})
               MERGE (musica:Musica {nome: {musica}})
               MERGE (interprete)-[:COMPOS]->(musica)"""
    @neo.query(query, :musico => musico, :musica => musica)
  end

  def manipula_gravacao(musico, musica)
    query = """MERGE (interprete:Musico {nome: {musico}})
               MERGE (musica:Musica {nome: {musica}})
               MERGE (interprete)-[:GRAVOU]->(musica)"""
    @neo.query(query, :musico => musico, :musica => musica)
  end
end