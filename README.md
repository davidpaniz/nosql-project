## Nosql

#### Build
[![Build Status](https://travis-ci.org/davidpaniz/nosql-project.svg?branch=master)](https://travis-ci.org/davidpaniz/nosql-project)

### Pré-requisitos

  * Docker e Docker compose -> https://docs.docker.com/compose/install/

### Iniciando os serviços

  * `./start` -> Usa docker-compose para inicializar o mongodb, riak, cassadra e neo4j

### Mongodb
  Após iniciar todos os serviços usando o `./start`, utilizer `./mongo`, que irá executar o `mongo` dentro do container do MongoDB