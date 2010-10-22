# test.rb
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'

DataMapper.setup(:default, ENV['DB_URL'])

require 'models'

enable :sessions

get '/' do
  
  @greeting = "Not logged in."
  if session[:user_id] then
    user = User.get(session[:user_id])
    @greeting = "Welcome, " + user.fname + " " + user.lname
  end
    
  
  haml :index
end

get '/register' do
  haml :register
end

get '/accountsettings' do
  if session[:user_id] then
   userId = session[:user_id]
   @user = User.get(session[:user_id])
  end
  haml :accountsettings
end 

post '/accountsettings' do
  if session[:user_id] then
    user = User.get(session[:user_id])
    user.fname = params[:fname]
    user.lname = params[:lname]
    user.password = params[:password]
    user.save()
   end
redirect '/'
end

post '/register' do
  @user = User.create(:username => params[:username], :password => params[:password], :fname => params[:fname], :lname => params[:lname], :email => params[:email])
  if @user
    session[:user_id] = @user.id
  end
  redirect '/'
end

post '/login' do
  @user = User.first(:username => params[:username], :password => params[:password])
  if @user then
    session[:user_id] = @user.id
  end
  
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  
  redirect '/'
end

get '/nav.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :nav
end

helpers do
  def renderPartial(view)
    haml :"#{view}"
    #Haml::Engine.new(IO.read(pathAndView)).render
  end
end
