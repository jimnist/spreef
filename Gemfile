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
# gem 'debugger', :group => :development

# using a fork of refinerycms that resolves the conflict between jquery-rails in refinery and spree
# not using refinerycms-authentication
gem 'refinerycms', :git => 'git://github.com/ngn33r/refinerycms.git', :branch => '2-1-stable' do
  gem 'refinerycms-core'
  gem 'refinerycms-dashboard'
  gem 'refinerycms-images'
  gem 'refinerycms-pages'
  gem 'refinerycms-resources'
  gem 'refinerycms-testing', :group => :test
end
gem 'refinerycms-i18n', :git => 'git://github.com/refinery/refinerycms-i18n.git', :branch => '2-1-stable'

gem 'spree', :github => 'spree/spree', :branch => "2-0-stable"
gem 'spree_i18n', :github => 'spree/spree_i18n', :branch => "2-0-stable"
gem 'spree_gateway', :github => 'spree/spree_gateway', :branch => "2-0-stable"
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-0-stable'