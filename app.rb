require 'rubygems'
require 'sinatra'
require 'haml'
require 'omniauth-github'
require 'sinatra/partial'
require 'monittr'
require 'fakeweb'
require 'data_mapper'

configure do
  enable :sessions
  use Rack::Session::Cookie
  use OmniAuth::Strategies::Developer
  use OmniAuth::Builder do
    provider :developer unless ENV['RACK_ENV'] == 'production'
  end
  use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end
  unless ENV['RACK_ENV'] == 'production'
    FakeWeb.register_uri(:get, 'http://localhost:2812/_status?format=xml', :body => File.read('status.xml') )
  end

  # setup datamapper
  unless ENV['DATABASE_URL'].nil?
    DataMapper.setup(:default, ENV['DATABASE_URL'])
  else
    DataMapper.setup(:default, "sqlite://#{Dir.pwd}/imonit.db")
  end

  # Datamapper classes
  class MonitServer
    include DataMapper::Resource
    property :id,         Serial
    property :url,        String
  end

  DataMapper.finalize
  DataMapper.auto_upgrade!
end

helpers do
  def current_user
    !session[:uid].nil?
  end

  def time_in_words(seconds)
    case seconds
    when 0..60
      "#{seconds        } seconds"
    when 60..3600
      value = seconds/60
      "#{value} minute#{value > 1 ? 's' : ''}"
    when 3600..86400
      value = seconds/3600
      "#{value} hour#{  value > 1 ? 's' : ''}"
    when 86400..604800
      value = seconds/86400
      "#{value} day#{   value > 1 ? 's' : ''}"
    when 604800..2419200
      value = seconds/604800
      "#{value} week#{  value > 1 ? 's' : ''}"
    else
      nil
    end
  end

end

before do
  pass if request.path_info =~ /^\/auth\//
  redirect to('/auth/developer') unless current_user
end

%w(get post).each do |method|
  send(method,'/auth/:provider/callback') do
    # probably you will need to create a user in the database too...
    session[:uid] = env['omniauth.auth']['uid']
    redirect to('/')
  end
end

get '/auth/failure' do
  # omniauth redirects to /auth/failure when it encounters a problem
  # so you can implement this as you please
end

get '/' do
  @cluster = Monittr::Cluster.new ['http://localhost:2812/']
  haml :index
end
