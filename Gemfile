source "https://rubygems.org"

gem 'sinatra'
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-github', '~> 1.1.2'
gem 'datamapper', '~> 1.2.0'
gem 'sinatra-partial', '~> 0.4.0'
gem 'haml', '~> 4.0.5'
gem 'monittr', git: 'https://github.com/softwareforgood/monittr.git', branch: 'master'

group :development do
  gem 'dm-sqlite-adapter', '~> 1.2.0'
  gem 'rerun'
  gem 'fakeweb'
  gem 'pry'
end

group :production do
  gem 'dm-postgres-adapter', '~> 1.2.0'
end
