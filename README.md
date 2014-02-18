# SimpleSet [![Build Status](https://travis-ci.org/sante-link/simple_set.png?branch=master)](https://travis-ci.org/sante-link/simple_set)

A Rails plugin which brings easy-to-use set-like functionality to ActiveRecord models.

This is based on [SimpleEnum](https://github.com/lwe/simple_enum).

## Installation

Add this line to your application's Gemfile:

```
gem 'simple_set'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install simple_set
```

## Usage

Add this to a model:

```ruby
class User < ActiveRecord::Base
  as_set :roles, [:accounting, :management]
end
```

Then create the required `roles_cd` column using migrations:

```ruby
class AddRolesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :roles_cd, :integer
  end
end
```

Now, it's possible to manage roles with maximum ease:

```ruby
bob = User.new
bob.roles = [:accounting]
bob.accounting?           #=> true
bob.management?           #=> false
bob.roles                 #=> [:accounting]
bob.roles_cd              #=> 1
```

## Gotchas

1. Acceptable values can be provided as an `Array` or as a `Hash`, the
   following lines are equivalent:

   ```ruby
   as_set :spoken_languages, [:english, :french, :german, :japanese]
   as_set :spoken_languages, {english: 1, french: 2, german: 4, japanese: 8}
   ```

   Reordering the array will change each element's value which is likely
   unwanted.  Either only append new elements to the `Array` notation or use
   the `Hash` notation.

2. Although the `Hash` notation is less intuitive than the `Array` notation, it
   allows some neat tricks:

   ```ruby
   class Pixel
     as_set :rgb, {
       red: 1,
       green: 2,
       blue: 4,

       yellow: 3,
       magenta: 5,
       cyan: 6,
       white: 7,
     }
   end

   x = Pixel.create(rgb: [:red, :blue])
   x.red?          #=> true
   x.green?        #=> false
   x.blue?         #=> true

   x.yellow?       #=> false
   x.magenta?      #=> true
   x.cyan?         #=> false

   x.white?        #=> false

   x.green = true
   x.white?        #=> true
   ```

3. If the shortcut methods (like `<symbol>?`, `<symbol>=` or `Klass.<symbol>`)
   conflict with something in your class, it’s possible to define a prefix:

   ```ruby
   class Lp < ActiveRecord::Base
     as_set :media_conditions, [:new, :sealed, :very_good, :good, :fair, :poor], prefix: true
   end

   Lp.media_condition_new #=> 1
   ```

   When `:prefix` is set to `true`, shortcut methods are prefixed by the
   _singularized name_ of the attribute.

   The `:prefix` option not only takes a boolean value as an argument, but
   instead can also be supplied a custom prefix (i.e. any string or symbol), so
   with `prefix: 'foo'` all shortcut methods would look like: `foo_<symbol>...`

4. Sometimes it might be useful to disable the generation of the shortcut
   methods (`<symbol>?`, `<symbol>=` and `Klass.<symbol>`), to do so just add
   the option `slim: true`:

   ```ruby
   class User
     as_set :spoken_languages, [:english, :french, :german, :japanese], slim: true
   end

   bob = User.create(spoken_languages: [:english, :french]
   bob.spoken_languages #=> [:english, :french]
   bob.french?          #=> throws NoMethodError: undefined method `french?'
   bob.french = false   #=> throws NoMethodError: undefined method `french='
   User.french          #=> throws NoMethodError: undefined method `french'
   ```

5. Easy Rails integration:

   Given a `User` is declared as:

   ```ruby
   class User < ActiveRecord::Base
     as_set :roles, [:management, :accounting, :human_resources]
   end
   ```

   Adjust strong parameters to allow roles assignment:

   ```ruby
   params.require(:user).permit(:roles => [])
   ```

   And then render a collection of checkboxes:

   ```haml
   = form_for @user do |f|
     = f.collection_check_boxes(:roles, User.roles, :to_sym, :to_sym) do |b|
       = b.check_box
       = b.label do
         = t("application.roles.#{b.text}")
   ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
