# README - Hito 2

Nota: Este readme solo incluye las funcionalidades nuevas en hito 3. Los otros readme: [Hito 1](../v0.1/README.md), [Hito 2](../v0.2/README.md).

## ¿Qué es Zwitscher?
Zwitscher es un clon de Twitter, desarollado en Ruby on Rails para la prueba del modulo 4 del curso "Fullstack developent" de Desafío Latam, generación 39.

La palabra es alemán y signífica "gorjear".

## Heroku
Zwitscher está disponible en heroku: https://zwitscher.herokuapp.com/

## Historia 1

> * Crear la página `/api/news` que permita obtener un json con los últimos 50 tweets, la estructura debe ser la siguiente:
> 
> ```json
> [
>  {
>    id: 1,
>     content: 'este es mi primer tweet',
>     user_id 3,
>     like_count: 10,
>     retweets_count: 20,
>     rewtitted_from: 2
>   },
>   {
>     id: 21,
>     content: 'No por mucho madrugar te lleva la corriente',
>     user_id 3,
>     like_count: 10,
>     retweets_count: 20,
>     rewtitted_from: 1
>   }
> ]
> ```

## Historia 2

> * Crear la página `/api/:fecha1/:fecha2` que entregue un json con todos los tweets entre ambas fechas.

## Historia 3

> * Se debe poder crear un tweet a través de la API. Para la creación del tweet el usuario deberá utilizar autenticación, sea mediante Devise o Basic Authentication.

## Historia 4 (opcional)

> * Se debe agregar roles a los usuarios de su aplicación, estos deben ser empresa y persona natural. Las empresas no podrán borrar sus tweets y las personas naturales solo podrán borrar (no modificar) sus tweets y no los de los demás.
