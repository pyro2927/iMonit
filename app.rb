require 'rubygems'
require 'sinatra'
require 'omniauth-github'

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
end

helpers do
  def current_user
    !session[:uid].nil?
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
  erb "Hello omniauth-twitter!"
end
