# README - Hito 2

Nota: Este readme solo incluye las funcionalidades nuevas en hito 2. El readme del hito 1 está [aquí](../v0.1/README.md).

## ¿Qué es Zwitscher?
Zwitscher es un clon de Twitter, desarollado en Ruby on Rails para la prueba del modulo 4 del curso "Fullstack developent" de Desafío Latam, generación 39.

La palabra es alemán y signífica "gorjear".

## Heroku
Zwitscher está disponible en heroku: https://zwitscher.herokuapp.com/

## Historia 1

> * Modificar la página principal para que, si el usuario ha iniciado sesión, se muestren únicamente los tweets de las personas que sigue.
> * Tip: Para conseguir esto se deberá crear un modelo Friend donde agregaremos cada usuario que el current_user siga. Además en este modelo agregaremos la columna friend_id para relacionar el id de los amigos del current_user con el user_id de cada tweet (para mayor referencia, revisar imagen adjunta).
> * Crear el scope tweets_for_me que recibirá una lista de ids de amigos del current_user y entregará todos los tweets relacionados a sus amigos.
> * Se debe mantener la paginación de tweet en 50 por página.
> * Añadir un área que muestra usuarios a los que se puede seguir

### El modelo "Following"

El hecho que un usuario sigue a otro usuario es representado mediante el modelo `Following`. Para generar el modelo:
```bash
rails g model Following user:belongs_to following_user:belongs_to
```

Después hay que modificar la migración que se generó para decirle a rails que el campo `following_user` también es una referencia a la tabla `Users`. Entonces hay que cambiar
```ruby
t.references :following_user, null: false, foreign_key: true
```
para
```ruby
t.references :following_user, null: false, foreign_key: { to_table: 'users' }
```

Después se puede correr la migración:
```bash
rails db:migrate
```

Para que los usuarios tengan acceso a sus seguidores y a los usuarios a que están siguiendo, hay que agregar lo siguiente a la clase `User`:
```ruby
has_many :following, class_name: 'Following', foreign_key: 'user_id'
has_many :followed_by, class_name: 'Following', foreign_key: 'following_user'
```

### La funcionalidad de "follow" y "unfollow"

Para facilitar el acceso, creé los siguientes métodos en `User`:
```ruby
def follow(other_user)
  Following.create(user: self, following_user: other_user)
end

def unfollow(other_user)
  following.where(following_user: other_user).destroy_all
end

def following?(other_user)
  following.where(following_user: other_user).positive?
end

def toggle_follow(other_user)
  if following?(other_user)
    unfollow(other_user)
  else
    follow(other_user)
  end
end

def followed_by_users
  followed_by.map(&:user)
end

alias followers followed_by_users

def following_users
  following.map(&:following_user)
end
```

Ahora falta la acción en el controlador. Hay que agregar lo siguiente a la clase `RegistrationsController`:
```ruby
def follow
  other_user = User.find(params[:id])
  current_user.toggle_follow(other_user)

  respond_to do |format|
    format.html { redirect_to root_path, notice: "You #{current_user.following?(other_user) ? 'are now' : 'stopped'} following #{other_user}" }
  end
end
```

Al final hay que agregar la ruta en `routes.rb`:
```ruby
devise_scope :user do
  post '/users/:id/follow', to: 'users/registrations#follow', as: 'user_follow'
end
```

### Mostrar solo los "tweets for me"

Un scope es un filtro, y en este caso solo debe mostrar los tweets que son de los usuarios seguidos por el current_user. El scope se agrega a la clase `Tweet`, se puede usar el método `following_users` creado en el paso anterior:
```ruby
scope :tweets_for_me, -> (user) { where(user: user.following_users) if user.present? }
```

Entonces, en la acción `TweetsController#index` se reemplaza
```ruby
@tweets = Tweet.order(id: :desc).page(params[:page])
```
por
```ruby
@tweets = Tweet.tweets_for_me(current_user).order(id: :desc).page(params[:page])
```

### Mostrar usuarios para seguir

Para generar una lista de los usuarios para seguir, hay que agregar un método a la clase `User` que retorna una lista de todos los usuarios a los que el usuario actual todavía no está siguiendo:
```ruby
def users_to_follow
  User.where.not(id: following.map(&:following_user_id)).limit(4)
end
```

Después se puede una vista parcial que muestra esa lista:
```erb
<div class="row row-cols-2 row-cols-md-4">
  <% current_user.users_to_follow.each do |u| %>
    <div class="p-2">
      <div class="user-to-follow">
        <img class="user-avatar" src="<%= u.pic_url %>" title="<%= u %>" />
        <div class="user-to-follow-header">
          <h5 class="user-to-follow-name"><%= u %></h5><br>
          <%= link_to(current_user.following?(u) ? 'Unfollow' : 'Follow', user_follow_path(u), method: :post, class: 'card-link') %>
        </div>
      </div>
    </div>
  <% end %>
</div>
```

Esta vista ya contiene un link para seguir y dejar de seguir a los usuarios.

## Historia 2

> * Se deberá crear un panel de control utilizando ActiveAdmin que liste todos los usuarios y pueda editarlos, cada usuario aparecerá junto al número de cuentas que sigue, cantidad de tweets realizados, cantidad de likes dados y la cantidad de retweets. Además deberán aparecer las acciones de borrar, y editar, donde borrar un usuario implica borrar en cascada todos sus tweets, likes y retweets.
> * Nota: Solo el admin podrá realizar estas tareas.
> * Opcional: Añadir una acción para bloquear un usuario. En caso de bloquear un usuario, se termina la sesión del usuario bloqueado.

## Historia 3

> * Implementar un buscador que pueda buscar tweets, para esto se debe hacer una búsqueda parcial ya que el contenido puede ser solo parte de un tweet.

## Historia 4

> * Debe permitirse la incorporación de hashtags en los contenidos (#estos #son #ejemplos), cada hashtag debe ser un link a una búsqueda.
