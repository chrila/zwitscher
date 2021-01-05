# README - Hito 2

Nota: Este readme solo incluye las funcionalidades nuevas en hito 2. El readme del hito 1 está [aquí](../v0.1/README.md).

## ¿Qué es Zwitscher?
Zwitscher es un clon de Twitter, desarollado en Ruby on Rails para la prueba del modulo 4 del curso "Fullstack developent" de Desafío Latam, generación 39.

La palabra es alemán y signífica "gorjear".

## Heroku
Zwitscher está disponible en heroku: https://zwitscher.herokuapp.com/

## Historia 1

> * Añadir un área con usuarios a los que se puede seguir
> * Modificar la página principal para que, si el usuario ha iniciado sesión, se muestren únicamente los tweets de las personas que sigue.
> * Tip: Para conseguir esto se deberá crear un modelo Friend donde agregaremos cada usuario que el current_user siga. Además en este modelo agregaremos la columna friend_id para relacionar el id de los amigos del current_user con el user_id de cada tweet (para mayor referencia, revisar imagen adjunta).
> * Crear el scope tweets_for_me que recibirá una lista de ids de amigos del current_user y entregará todos los tweets relacionados a sus amigos.
> * Se debe mantener la paginación de tweet en 50 por página.

## Historia 2

> * Se deberá crear un panel de control utilizando ActiveAdmin que liste todos los usuarios y pueda editarlos, cada usuario aparecerá junto al número de cuentas que sigue, cantidad de tweets realizados, cantidad de likes dados y la cantidad de retweets. Además deberán aparecer las acciones de borrar, editar y bloquear, donde borrar un usuario implica borrar en cascada todos sus tweets, likes y retweets.
> * Nota: Solo el admin podrá realizar estas tareas.
> * En caso de bloquear un usuario, se termina la sesión del usuario bloqueado.

## Historia 3

> * Implementar un buscador que pueda buscar tweets, para esto se debe hacer una búsqueda parcial ya que el contenido puede ser solo parte de un tweet.

## Historia 4

> * Debe permitirse la incorporación de hashtags en los contenidos (#estos #son #ejemplos), cada hashtag debe ser un link a una búsqueda.
