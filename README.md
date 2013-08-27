spreef
======

example rails 3.2 app integrating spree 2.0 and refinerycms 2.1

ideally, we want to integrate the users, but you COULD run a site with the two user systems.

# THIS IS IN PROGRESS

### tags and branches
these correspond to steps along the way
* rails_only (tag)
* spree (branch)
* spree_and_refinery (branch)
* master (branch) integrated spree users with refinery

### adapted from
* https://gist.github.com/gnepud/5827411
* http://www.synaptian.com/blog/posts/integrating-refinery-rails-3-2-into-your-existing-rails-app
* http://refinerycms.com/guides/with-an-existing-rails-31-devise-app

### TODO
* review app/assets/stylesheets/application.css - move that code?
* create a pull request for refinerycms to be compatible with spree

## app creation steps


- - -
### set up rails
- - -

run some commands
```sh
$ rvm gemset create spreef
$ rvm use 2.0.0
$ rvm gemset create spreef
$ rvm gemset use spreef
$ gem install rails -v=3.2.14
$ cd spreef
$ rvm --create --ruby-version use ruby-2.0.0-p247@spreef
$ rails new .
```

set up your database.yml and make sure that you can run rails locally. if your db config allows it, run ```rake db:create``` otherwise set up the databases manually.

```sh
$ bundle exec rails s
```

__rails_only__ tag taken here.


### install spree
- - -

```sh
$ gem install spree_cmd
$  spree install --version=2.0.5 --skip-install-data
Would you like to install the default gateways? (Recommended) (yes/no) [yes] yes
Would you like to install the default authentication system? (yes/no) [yes] yes
```

change the __Gemfile__ to the following. this has the spree and refinery gems that we'll be using. this uses a fork of refinerycms that deals with the conflict in gem requirements for jquery-rails. note this gemfile is using MySQL, adjust if
you are not.

```ruby
source 'https://rubygems.org'

gem 'rails', '3.2.14'

gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '~> 3.0.0'
gem 'jquery-ui-rails', '~> 4.0.0'

gem 'awesome_nested_set', '2.1.5'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# using a fork of refinerycms that resolves the conflict between jquery-rails in refinery and spree
# this ommits refinerycms-authentication
#gem 'refinerycms', :git => 'git://github.com/ngn33r/refinerycms.git', :branch => '2-1-stable' do
#  gem 'refinerycms-core'
#  gem 'refinerycms-dashboard'
#  gem 'refinerycms-images'
#  gem 'refinerycms-pages'
#  gem 'refinerycms-resources'
#  gem 'refinerycms-testing', :group => :test
#end
#gem 'refinerycms-i18n', :git => 'git://github.com/refinery/refinerycms-i18n.git', :branch => '2-1-stable'

gem 'spree', :github => 'spree/spree', :branch => "2-0-stable"
gem 'spree_i18n', :github => 'spree/spree_i18n', :branch => "2-0-stable"
gem 'spree_gateway', :github => 'spree/spree_gateway', :branch => "2-0-stable"
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-0-stable'
```

```sh
$ bundle update
$ rails g spree:install --migrate=false --sample=false --seed=false
$ rails g spree_i18n:install
   Would you like to run the migrations now? [Y/n] n
```

change spree to use the devise user by setting __Spree.user_class__ in __config/initializers/spree.rb__
```ruby
Spree.user_class = "Spree::User"
```

run the migrations, seed the database and . you will be asked to create the __admin__ user somewhere in there.
```sh
$ rake railties:install:migrations db:migrate db:seed
```

optionally load spree_sample data - __NOTE__ the images that are put in the tree are .gitignored in the repo. you will want to run this again if you have forked this repo.
```sh
$ rake spree_sample:load
```

clean up and test out spree. make sure you can log in as a (frontend)[http://localhost:3000/] and (backend)[http://localhost:3000/admin] user.
```sh
$ rm public/index.html
$ rails s
```

### add refinery
- - -

uncomment the refinery gems in the Gemfile
```ruby
gem 'refinerycms', :git => 'git://github.com/ngn33r/refinerycms.git', :branch => '2-1-stable' do
  gem 'refinerycms-core'
  gem 'refinerycms-dashboard'
  gem 'refinerycms-images'
  gem 'refinerycms-pages'
  gem 'refinerycms-resources'
  gem 'refinerycms-testing', :group => :test
end
gem 'refinerycms-i18n', :git => 'git://github.com/refinery/refinerycms-i18n.git', :branch => '2-1-stable'
```


# OLD INSTRUCTIONS
- - -


```sh
$ bundle install
$ rails generate refinery:cms --fresh-installation --skip-db
```

change the order of Engine route mounting in __config/routes.rb__ by making the top few lines (after the very first line) read like this:
```ruby
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'

  # This line mounts Refinery's routes at the root of your application.
  # This means, any requests to the root URL of your application will go to Refinery::PagesController#home.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Refinery relies on it being the default of "refinery"
  mount Refinery::Core::Engine, :at => '/'
```

monkey patch for __will_paginate__ goes in __config/initializers/will_paginate.rb__
```ruby
if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        alias_method :per, :per_page
        alias_method :num_pages, :total_pages
      end
    end
  end
end
```

check your database.yml settings and peruse the sample files that refinery set up for us, but delete them once yours is set up
```sh
$ rm config/database.yml.mysql config/database.yml.postgresql config/database.yml.sqlite3
```

comment out the spree __load_seed__ lines in __db/seeds.rb__ since they have already been run.

run the migrations and seed the database.
```sh
$ rake railties:install:migrations db:migrate db:seed
```

run the server locally and test that you can log in to spree [frontend](http://localhost:3000/) and [backend](http://localhost:3000/admin] user AND that you can create a refinery user via the [refinery backend](http://localhost:3000/refinery). for extra credit, create a page in the refinery back end and see that you can browse to it.
```sh
$ rails s
```

# SCREEEEEEECH
not working. can't log in to spree. but really, that's not what i'm looking for. so on to integrating authentication.

### use spree users for refinery authentication
- - -

now we need to:
* emulate the refinery user model
* override some refinery functionality
* initialize a spree user with refinery roles

#### emulate the refinery user model
- - -



#### override some refinery functionality
- - -

much of the overriding is done by adding __config/initializers/refinery/user.rb__ with the content in the file.

we also need to override the refinery admin view to log out with spree

```sh
$ rake refinery:override view=refinery/_site_bar*
```

change the logout link to go to spree in __app/views/refinery/_site_bar.html.erb__
```ruby
<%= link_to t('.log_out', site_bar_translate_locale_args), spree.destroy_spree_user_session_path, :id => 'logout' %>
```


#### initialize a spree user with refinery roles
- - -

add the following lines to __db/seeds.rb__, (temporarily) comment out the ones above that have already been run
```ruby
Spree::Role.create(:title => 'Refinery')
Spree::Role.create(:title => 'Superuser')
```

load that . .
```sh
$ rake db:seed
```

go into the console and add those roles to the admin user created with the spree installation
```sh
2.0.0p247 :001 > user = Spree::User.first
2.0.0p247 :001 > user.roles << Spree::Role.find_by_title('Refinery')
2.0.0p247 :001 > user.roles << Spree::Role.find_by_title('Superuser')
2.0.0p247 :001 > user.save
```
