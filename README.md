# README

## ¿Qué es Zwitscher?
Zwitscher es un clon de Twitter, desarollado en Ruby on Rails para la prueba del modulo 4 del curso "Fullstack developent" de Desafío Latam, generación 39.

La palabra es alemán y signífica "gorjear".

## Heroku
Zwitscher está disponible en heroku: https://zwitscher.herokuapp.com/

## Historia 1
> * El modelo debe llamarse user.
> * La visita al registrarse debe ingresar nombre usuario, foto de perfil (url), email y password.

Para la autenticación en este proyecto se usa `devise`.
```ruby
# use devise for authentication
gem 'devise'
```
Para instalar devise en el proyecto:
```bash
rails devise:install
```
Para generar el modelo `user`: (por defecto viene con los campos `password` y `email`)
```bash
rails g devise user
```
Para gregar los campos para el nombre usuario y foto de perfil al modelo:
```
rails g migration AddNameAndPictureToUser name pic_url
rails db:migrate
```

Para agregar los campos a los formularios, primero hay que generar las vistas y controladores de devise y después se puede editarlos para agregar los campos adicionales.
```bash
rails g devise:views users
rails g devise:controllers users
```
Importante: para usar las vistas y los controladores generados, hay que hacer un cambio en `config/routes.rb`:

cambiar
```ruby
devise_for :users
```
para
```ruby
devise_for :users, controllers: {
  registrations: 'users/registrations',
  sessions: 'users/sessions'
}
```

Ahora, a las vistas
* `app/views/users/registrations/new.html.erb`
* `app/views/users/registrations/edit.html.erb`

hay que agregar los dos campos nuevos:

```erb
<div class="form-group">
  <%= f.label :name %>
  <%= f.text_field :name, autofocus: true, autocomplete: "name", class: "form-control" %>
</div>

<div class="form-group">
  <%= f.label :pic_url %>
  <%= f.text_field :pic_url, autocomplete: "profile picture URL", class: "form-control" %>
</div>
```

En el controlador
* `app/controllers/users/registrations_controller.rb`

hay que agregar/habilitar las siguientes líneas:

```ruby
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :pic_url])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :pic_url])
  end
```

> * Una visita debe poder registrarse utilizando el link de registro en la barra de navegación.

La acción para registrarse (crear un nuevo usuario) es `users#registrations#new`, así que hay que agregar un link al layout:

```erb
<%= link_to "Sign Up", new_user_registration_path %>
```

> * Si una visita ya tiene usuario deberá utilizar el link de ingreso y llenará los campos: email y password antes de hacer click en ingresar.

El link para el login se agrega así:

```erb
<%= link_to "Sign In", new_user_session_path %>
```

> * Al registrarse o ingresar se le debe redirigir a la página de inicio y mostrar una alerta con el mensaje de "bienvenido".

Para mostrar alertas, hay que agregar los siguientes elementos al layout `app/views/layouts/application.html.erb`

```erb
<% if notice %>
    <%= notice %>
<% end %>
<% if alert %>
    <%= alert %>
<% end %>
```

Ahora, para cambiar los mensajes, se puede cambiar los textos en `config/locales/devise.en.yml`:

```ruby
signed_in: "bienvenido"
signed_out: "chao"
```

## Historia 2
> * Los modelos debe llamarse tweet y like.

Para generar los modelos tweet y like:
```bash
rails g model tweet content:text user:belongs_to
rails g model like user:belongs_to tweet:belongs_to
rails g migration AddTweetRefToTweet tweet:belongs_to
```
En la última migración hay que agregar `null: true`, porque esa referencia es opcional (un tweet no siempre es un retweet):
```ruby
class AddTweetRefToTweet < ActiveRecord::Migration[6.0]
  def change
    add_reference :tweets, :tweet, null: true, foreign_key: true
  end
end
```
Después, correr las migraciones:
```bash
rails db:migrate
```

Después hay que agregar las relaciones a los modelos
* `app/models/user.rb`:
```ruby
has_many :tweets
has_many :likes
```
* `app/models/tweet.rb`:
```ruby
belongs_to :user
has_many :likes
has_many :retweets, class_name: 'Tweet', foreign_key: :tweet_id
belongs_to :original_tweet, class_name: 'Tweet', foreign_key: :tweet_id, optional: true
```
* `app/models/like.rb`:
```ruby
belongs_to :user
belongs_to :tweet
```

Al final, el modelo se ve así:

![ERD model](doc/erd.png)

> * Una visita debe poder entrar a la página de inicio y ver los últimos 50 tweets.

Generar el controlador para los tweets:
```bash
rails g controller tweets
```

Agregar las rutas en `config/routes.rb`:
```ruby
resources :tweets
```

La acción `TweetsController.index` debe cargar los últimos 50 tweets:
```ruby
def index
  @tweets = Tweet.order(id: :desc).limit(50)
end
```

Para cambiar el root del sitio, hay que agregar lo siguiente a `config/routes.rb`:
```ruby
root 'tweets#index'
```

> * Cada tweet debe mostrar el contenido, la foto del autor (url a la foto), la cantidad de likes y la cantidad de retweets.

Para mostrar el contenido del tweet, se puede sacar la información de la colección `@tweets` del `TweetsController`:

```erb
<div class="row row-cols-1 row-cols-xl-2">
  <% @tweets.each do |t| %>
    <div class="col mb-4">
      <div class="card card-tweet">
        <div class="card-body">
          <h5 class="card-title"><img class="user-avatar" src="<%= t.user.pic_url %>" /> <%= t.user %></h5>
          <small class="text-muted"><%= "Likes: #{tweet.like_count}" %></small> | 
          <small class="text-muted"><%= "Retweets: #{tweet.retweet_count}" %></small>
          <p class="card-text"><%= t.content %></p>
        </div>
      </div>
    </div>
  <% end %>
</div> 
```

## Historia 3
> * Estos tweets deben estar paginados y debe haber un link llamado "mostrar más tweets", al presionarlo nos llevará a los siguientes 50 tweets.

Para la paginación en este proyecto se usa la gema `kaminari`. Una vez agregado al `Gemfile`, el uso es bien simple.
```ruby
gem 'kaminari'
```

Se puede definir directamente en el modelo cuántos elementos se debe mostrar per página:
```ruby
paginates_per 50
```

Para cargar una página, kaminari agrega el scope `page` para el uso en el controlador `TweetsController`:
```ruby
def index
  @tweets = Tweet.order(id: :desc).page(params[:page])
end
```

Finalmente, a la vista `app/views/tweets/index.html.erb` al pie de la página se agrega los links para cambiar de página:
```erb
<div class="my-3">
  <%= paginate @tweets %>
</div> 
```

## Historia 4
> * Al principio de la página debe haber una formulario que nos permita ingresar un nuevo tweet, al crear un tweet el usuario será redirigido a la página de inicio.
> * El formulario solo debe mostarse a los usuarios y no a las visitas.

El formulario se puede hacer aparte en una vista parcial:
```erb
<%= form_with(model: tweet, local: true) do |form| %>
  <div class="form-group">
    <%= form.text_area :content, placeholder: "Your message ...", class: "form-control" %>
  </div>

  <div class="form-group">
    <%= form.submit "Tweet!", class: "btn btn-primary" %>
  </div>
<% end %> 
```

Para integrarlo a la página principal, a la vista `app/views/tweets/index.html.erb` hay que agregar:
```erb
<% if signed_in? %>
  <div class="my-3">
    <%= render 'tweet_form', tweet: Tweet.new %>
  </div>
<% end %>
```
El helper `signed_in?` es parte de devise.

> * Se debe validar que el tweet tenga contenido.

Al modelo `Tweets` hay que agregar:
```ruby
validates :content, presence: true
```

## Historia 5
> * Un usuario puede hacer like en un tweet, al hacerlo será redirigido a la página de inicio
> * Se debe mostrar un icono distinto para cuando un usuario ha hecho like.
> * Un usuario no puede hacer dos likes sobre el mismo tweet. Por lo tanto, se le debe quitar el like en el caso de que vuelva a hacer click en el botón.

Para hacer un like/dislike, hay que agregar un poco de lógica al modelo del `Tweet`:
```ruby
[...]

def liked?(user)
  likes.where(user: user).size.positive?
end

def like(user)
  Like.create(user: user, tweet: self)
end

def unlike(user)
  likes.where(user: user).destroy_all
end

def toggle_like(user)
  if liked?(user)
    unlike(user)
  else
    like(user)
  end
end

[...]
```

Después, se agrega la acción al `TweetsController`
```ruby
[...]

def like
  @tweet = Tweet.find(params[:id])
  @tweet.toggle_like(current_user)

  respond_to do |format|
    format.html { redirect_to root_path, notice: "Tweet #{@tweet.liked?(current_user) ? 'liked' : 'unliked'}" }
  end
end

[...]
```

Finalemente, falta una ruta para la nueva acción:
```ruby
post 'tweets/:id/like', to: 'tweets#like', as: 'tweet_like'
```

Para integrar la funcionalidad a la vista, se puede poner un link así:
```erb
<%= link_to "#{t.liked?(current_user) ? 'unlike' : 'like'}", tweet_like_path(t), method: :post %>
```

## Historia 6
> * Un usuario puede hacer un retweet haciendo click en la acción rt (retweet) de un tweet, esto hará que ingrese un nuevo tweet con el mismo contenido pero además referenciando al tweet original.

Un retweet es un tweet con un vínculo a otro tweet (el `original_tweet`). Yo elegí de en vez de poner el mismo contenido, poner "Retweet" y mostrar el tweet original en la vista.

La lógica de retweet en el modelo `Tweet`:
```ruby
def retweet(user)
  Tweet.create(original_tweet: self, content: 'Retweet', user: user)
end
```

En el controller `TweetsController`:
```ruby
def retweet
  @tweet = Tweet.find(params[:id])
  new_tweet = Tweet.new(user: current_user, content: 'Retweet', original_tweet: @tweet)

  respond_to do |format|
    if new_tweet.save
      format.html { redirect_to root_path, notice: 'Retweeted!' }
    else
      format.html { redirect_to root_path, alert: 'Retweet not successful.' }
    end
  end
end
```

Y finalmente la ruta:
```ruby
post 'tweets/:id/retweet', to: 'tweets#retweet', as: 'tweet_retweet'
```

Así se puede hacer un retweet con el siguiente link:
```erb
<%= link_to "retweet", tweet_retweet_path(t), method: :post %>
```

## Historia 7
> * Haciendo click en la fecha del tweet se debe ir al detalle del tweet y dentro del detalle debe aparecer la foto de todas las personas que han dado like al tweet.
> * La fecha del tweet debe aparecer como tiempo en minutos desde la fecha de creación u horas si es mayor de 60 minutos.

Para mostrar las fotos de los usuarios que han dado like al tweet, se agrega lo siguiente a la vista `app/views/tweets/show.html.erb`:
```erb
<strong>Likes:</strong> <%= @tweet.like_count %>
<ul>
  <% @tweet.likes.each do |like| %>
    <li class="tweet-detail-li">
      <img class="user-avatar" src="<%= like.user.pic_url %>" title="<%= like.user %>" />
    </li>
  <% end %>
</ul>
```

Y en la vista `index`, se agrega la fecha al tweet, que también es el link a la vista `show`:
```erb
<%= link_to "#{time_ago_in_words(tweet.created_at)} ago", tweet_path(tweet) %>
```
