spreef
======

example rails 3.2 app integrating spree 2.0 and refinerycms 2.1

### adapted from
* http://refinerycms.com/guides/with-an-existing-rails-31-devise-app
* https://gist.github.com/gnepud/5827411
* http://www.synaptian.com/blog/posts/integrating-refinery-rails-3-2-into-your-existing-rails-app
* http://refinerycms.com/guides/with-an-existing-rails-31-devise-app

### TODO
* share helpers accross spree and refinery (ApplicationController)
* test login on refinery
* create a pull request for refinerycms to be jquery-rails compatible with spree
* add nested layout strategy

## app creation steps


### set up rails

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

### install spree

```sh
$ gem install spree_cmd
$  spree install --version=2.0.5 --skip-install-data
Would you like to install the default gateways? (Recommended) (yes/no) [yes] yes
Would you like to install the default authentication system? (yes/no) [yes] yes
```

modify the __Gemfile__ to be just like the one in this app (more or less). this has the spree and refinery gems that we'll be using. this uses my own fork of refinerycms that deals with the conflict in gem requirements for jquery-rails between spree and refinery. it also does not have __refinerycms-authentication__ as a dependncy for __refinerycms-core__. note this gemfile is using MySQL, adjust if you are not.

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

add monkey patch for __will_paginate__ goes in __config/initializers/will_paginate.rb__
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

check your database.yml settings and peruse the sample files that refinery set up for us, but delete them once yours is set up
```sh
$ rm config/database.yml.mysql config/database.yml.postgresql config/database.yml.sqlite3
```

comment out the spree __load_seed__ lines in __db/seeds.rb__ since they have already been run.

run the migrations and seed the database.
```sh
$ rake db:migrate db:seed
```

run the server locally and test that you can log in to spree [frontend](http://localhost:3000/) and [backend](http://localhost:3000/admin]
```sh
$ rails s
```

### set up spree users for refinery authentication

create a Spree::UserPlugin model by running this and then editing the files a wee bit
```sh
$ rails g model UserPlugin user_id:integer name:string position:integer
```

final files, all of which you will want in your app
* db/migrate/20130827034717_spree_refinery_user_modifications.rb
* app/models/spree/refinery_user_plugin.rb
* app/models/spree/user_decorator.rb
* app/models/spree/role_decorator.rb

run the migrations
```sh
$ rake db:migrate
```

add these files to your app
* lib/refinery/refinery_patch.rb
* lib/refinery/restrict_refinery_to_refinery_users.rb
* app/decorators/controllers/refinery/admin/base_controller_decorator.rb

add the guts of the following to your __config/application.rb__
```ruby
module ExistingApp
  class Application < Rails::Application
    ...
    # Load files from the lib directory, including subfolders.
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.before_initialize do
      require 'refinery_patch'
      require 'restrict_refinery_to_refinery_users'
    end

    extend Refinery::Engine
    after_inclusion do
      [::ApplicationController, ::ApplicationHelper, ::Refinery::AdminController].each do |c|
        c.send :include, ::RefineryPatch
      end

      ::Refinery::AdminController.send :include, ::RestrictRefineryToRefineryUsers
      ::Refinery::AdminController.send :before_filter, :restrict_refinery_to_refinery_users
    end
  end
end
```

add this to your __app/controllers/application_controller.rb__
```ruby
  # include refinerycms and spree helpers so they
  # are available throughout the application
  helper Refinery::Core::Engine.helpers
  include Spree::Core::ControllerHelpers
  include Spree::BaseHelper
  helper 'spree/base'
  helper 'spree/products'
```

set up the spree admin user to be a Refinery Superuser with some plugins
```sh
$ rails console
> u = Spree::User.first
> u.spree_roles << Spree::Role.create(:name=>"Superuser")
> u.spree_roles << Spree::Role.create(:name=>"Refinery")
> u.plugins =["refinery_pages","refinery_images"]
> u.save
> exit
```

run the server locally and test that you can log in to spree [frontend](http://localhost:3000/) and [backend](http://localhost:3000/admin] user AND that you can browse to refinery when your are logged in  [refinery backend](http://localhost:3000/refinery).
```sh
$ rails s
```
