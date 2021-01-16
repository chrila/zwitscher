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

### El controlador ApiController

Para crear los endpoint para la API, primero hay que generar un nuevo controller (dentro del namespace `Api`):
```bash
rails g controller api/api
```

Después, hay que cambiar la clase `ApiController` para heredar de `ActionController::API` en vez de `ApplicationController`:
```ruby
class Api::ApiController < ActionController::API
```

### La lógica

Ahora se puede implementar la lógica. En la clase `Tweet` se agrega un scope `news`:
```ruby
scope :news, -> { last(50) }
```

En la clase `ApiController` se implementa el método `tweet_hash_array` para generar un array de tweet hashes y el método `news`, que usa el scope que definimos anteriormente:
```ruby
def news
  render json: tweet_hash_array(Tweet.news)
end

private

def tweet_hash_array(tweets)
  tweets_arr = []
  tweets.each do |t|
    tweet = { 
      id: t.id,
      content: t.content,
      user_id: t.user_id,
      like_count: t.like_count,
      retweets_count: t.retweet_count,
      retweeted_from: t.tweet_id
    }
    tweets_arr.push(tweet)
  end
  tweets_arr
end
```

### La ruta

Al final solo falta la ruta:
```ruby
namespace :api do
  get 'news', to: 'api#news'
end
```

### Uso

Ejemplo: `GET` to `http://localhost:3000/api/news`

Respuesta (body):
```json
[
    {
        "id": 210,
        "content": "To alcohol! The cause of, and solution to, all of life's problems.",
        "user_id": 7,
        "like_count": 5,
        "retweets_count": 0,
        "retweeted_from": null
    },
    {
        "id": 212,
        "content": "Retweet",
        "user_id": 14,
        "like_count": 4,
        "retweets_count": 0,
        "retweeted_from": 88
    },
...
]
```

## Historia 2

> * Crear la página `/api/:fecha1/:fecha2` que entregue un json con todos los tweets entre ambas fechas.

Ese punto es similar al anterior. Agregamos un scope al modelo, un método al controlador y finalmente una ruta.

El scope en la clase `Tweet`:
```ruby
scope :between, -> (date_from, date_to) { where(created_at: date_from..date_to) }
```

El método en el controlador `ApiController`:
```ruby
def between
  render json: tweet_hash_array(Tweet.between(params[:date_from], params[:date_to]))
end
```

La ruta:
```ruby
namespace :api do
  get 'news', to: 'api#news'
  get ':date_from/:date_to', to: 'api#between', as: 'between'
end
```

### Uso

Ejemplo: `GET` to `http://localhost:3000/api/2021-01-01/2021-01-20`

Respuesta (body):
```json
[
    {
        "id": 1,
        "content": "The worst thing about prison was the Dementors. They were flying all over the place and they were scary and they'd come down and they'd suck the soul out of your body and it hurt!",
        "user_id": 13,
        "like_count": 1,
        "retweets_count": 2,
        "retweeted_from": null
    },
    {
        "id": 2,
        "content": "Retweet",
        "user_id": 1,
        "like_count": 2,
        "retweets_count": 1,
        "retweeted_from": 1
    },
...
]
```

## Historia 3

> * Se debe poder crear un tweet a través de la API. Para la creación del tweet el usuario deberá utilizar autenticación, sea mediante Devise o Basic Authentication.

Este punto era lo más difícil. Primero hay que habilitar la autenticación a través del API. Decidí hacerlo en base de devise y token mediante la gema `devise_token_auth`.

### Autenticación usando la gema `devise_token_auth`

Primero, hay que agregarlo al Gemfile:
```ruby
gem 'devise_token_auth'
```

Correr `bundle`

Después hay que correr un generador:
```bash
rails g devise_token_auth:install User auth
```

Eso genera la configuración, las rutas y también intenta crear el modelo `User`. En nuestro caso el modelo ya existe, por eso hay que eliminar la migración creada por el generador y crear una que agregue los campos necesarios al modelo que ya existe:
```ruby
class AddTokensToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :tokens, :text

    User.reset_column_information

    User.find_each do |user|
      user.uid = user.email
      user.provider = 'email'
      user.save!
    end

    add_index :users, [:uid, :provider], unique: true
  end

  def down
    remove_columns :users, :provider, :uid, :tokens
  end
end
```

Después: correr la migración:
```bash
rails db:migrate
```

A la clase `User` hay que agregar la siguiente línea:
```ruby
include DeviseTokenAuth::Concerns::User
```

Al controlador `ApiController` se agrega esa línea:
```ruby
include DeviseTokenAuth::Concerns::SetUserByToken
```

Al final, hay que mover la línea que el generador añadió a `routes.rb` al bloque de los API endpoints:
```
namespace :api do
  mount_devise_token_auth_for 'User', at: 'auth'
  get 'news', to: 'api#news'
  get ':date_from/:date_to', to: 'api#between', as: 'between'
end
```

### El endpoint para crear un tweet

En el controlador `ApiController`:

```ruby
before_action :authenticate_user!, only: [:create]

def create
  @tweet = Tweet.new(tweet_params)
  @tweet.user = current_user

  if @tweet.save
    render json: { status: 'success' }
  else
    render json: { status: 'error' }
  end
end

private

def tweet_params
  params.require(:tweet).permit(:content)
end
```

Después, la ruta:
```ruby
namespace :api do
  mount_devise_token_auth_for 'User', at: 'auth'
  get 'news', to: 'api#news'
  get ':date_from/:date_to', to: 'api#between', as: 'between'
  post 'create', to: 'api#create', as: 'create'
end
```

### Cómo autenticarse?

Con el método del token funciona así:

* Cliente: manda un request de tipo POST a la ruta sign_in, con el login en el body:

`POST` to `http://localhost:3000/api/auth/sign_in`

Body:
```json
{
    "email": "user@email.com",
    "password": "password"
}
```

* Servidor: responde con los datos del usuario en el body y - importante - el token en el header.

Body:
```json
{
    "data": {
        "banned": false,
        "id": 15,
        "email": "user@email.com",
        "provider": "email",
        "uid": "user@email.com",
        "pic_url": "https://picsum.photos/1014/600",
        "name": "User",
        "user_type": null
    }
}
```

Header:
```json
access-token: WN9bNmm9uKXHbKWvDRdJjQ
client: GgDngXhplFYV3Ga6TpC-fg
uid: user@email.com
```

Después, en cada request que necesita que el usuario sea autenticado, hay que incluir estos datos en el header.

### Cómo crear un tweet?

Dado el caso que el usuario ya se autenticó (según el punto anterior), se puede mandar un request como lo siguiente:

`POST` to `http://localhost:3000/api/create`

Body:
```json
{
    "tweet": {
        "content": "my first tweet created via API!!"
    }
}
```

Y lo importante es incluir las informaciones que se recibió con el login anteriormente en el header del request:

Header:
```json
access-token: WN9bNmm9uKXHbKWvDRdJjQ
client: GgDngXhplFYV3Ga6TpC-fg
uid: user@email.com
```

## Historia 4 (opcional)

> * Se debe agregar roles a los usuarios de su aplicación, estos deben ser empresa y persona natural. Las empresas no podrán borrar sus tweets y las personas naturales solo podrán borrar (no modificar) sus tweets y no los de los demás.

Para solucionar este punto, se agregó un campo `user_type` al modelo `User` (usando un `enum`). Para verificar las habilidades, se usó la gema `CanCanCan`.

### Borrar tweets

Basicamente sólo faltó implementar el método `TweetsController.destroy` cómo siguiente:

```ruby
def destroy
  Tweet.find(params[:id]).destroy

  respond_to do |format|
    format.html { redirect_to root_path, notice: 'Tweet deleted.' }
  end
end
```

Para que también se borre los likes y retweets, hay que agregar `dependent: :delete_all` a las `has_many` en el modelo `Tweet`.

### El campo `user_type`

Para distinguir los tipos de usuarios, se agrega un campo al modelo `User`. Primero, se genera la migración:

```bash
rails g migration AddUserTypeToUser user_type:integer
```

Correr la migración:
```bash
rails db:migrate
```

Después, se define el enum en el modelo `User`:
```ruby
enum user_type: [ :personal, :corporate ]
```

Ahora solo falta agregar el campo a los formularios `app/views/users/registrations/edit.html.erb` y `new.html.erb`:

```erb
<div class="form-group">
  <label for="user_type">User type</label>
    <%= f.select :user_type, User.user_types.keys, class: "form-control" %>
</div>
```

... y a las strong params del `RegistrationsController`:
```ruby
def configure_sign_up_params
  devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :pic_url, :user_type])
end

def configure_account_update_params
  devise_parameter_sanitizer.permit(:account_update, keys: [:name, :pic_url, :user_type])
end
```

### CanCanCan
Con CanCanCan, se puede definir los requisitos para que sea permitido ejecutar un método.

Primero, la gema:
```ruby
gem 'cancancan'
```

Después correr bundle.

Ahora se puede definir la condición para que un usuario pueda borrar un tweet. Eso se hace en el archivo `app/models/ability.rb`:

```ruby
include CanCan::Ability

def initialize(user)
  if user.present?
  if user.present? && user.user_type == 'personal'
    can :destroy, Tweet, user_id: user.id
  end
end
```

Eso significa que
* el usuario tiene que estar presente (logged in)
* el usuario tiene que ser del tipo 'personal'
* el user_id del tweet tiene que corresponder con el ID del usuario

Para usar esa información, se agrega el link a la función de borrar a la vista parcial de tweet:

```erb
<% if can? :destroy, tweet %>
  <%= link_to tweet_path(tweet), method: :delete, data: { confirm: 'Are you sure?' }, class: "px-2" do %>
    <%= fa_icon('trash-alt', type: :solid) %>
  <% end %>
<% end %>
```
