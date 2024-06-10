# Video Downloader UI

Projeto de cosntrução de uma interface de usuário para download de vídeos.

Este projeto visa exercitar o uso do framework Sinatra e o uso de bibliotecas de execução de jobs em segundo plano
(background jobs) para a execução de tarefas assíncronas.

## Instalação

Para instalar a aplicação, basta baixar o projeto tendo uma versão do Ruby superior a versão 3.0 e o bundler.

`bundler install && gem install foreman`

Com isso feito, basta subir a aplicação com o comando:

`foreman start`

## Funcionamento e decisões de projeto

O projeto utiliza a ferramenta `yt-dlp` para baixar videos, simulando um processo demorado e com isso, utiliza o Sucker
Punch para a execução do job em segundo plano.

A interface web é criada usando o Bootstrap, uma vez que o foco não é trabalhar a interface ou skills de CSS, e o Sinatra como framework web.

A execução dos jobs é feita de forma assíncrona, permitindo que o usuário possa continuar utilizando a aplicação enquanto o download é feito.

Esse comportamento foi criado por meio do Sucker Punch, que é uma gem que implementa a execução desses jobs por uso de threads, dispensando a necessidades de infraestruturas extras como o Redis ou bancos de dados, usados por outras gems.

Os videos são baixados em um diretório e suas thumbnails em um outro diretório para possibilitar criar telas de exibição
aprimoradas no futuro.

Até o momento não foi pensando no uso de um banco de dados para manter as informações, porém no futuro, caso ainda
queira evoluir os estudos nesse projeto, penso em usar o SQLite para criar categorias, manter os metadados dos videos e
talvez criar playlists por usuário.

## Autor

Daniel Vinciguerra
