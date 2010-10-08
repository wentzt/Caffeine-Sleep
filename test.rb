# test.rb
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'

DataMapper.setup(:default, ENV['DB_URL'])

$user = nil

get '/' do
  
  @greeting = "Not logged in."
  if $user then
    @greeting = "Welcome, " + $user.fname + " " + $user.lname
  end
    
  
  haml :index
end

get '/register' do
  haml :register
end

post '/register' do
  
  redirect ('/')
end

post '/login' do
  $user = User.first(:username => params[:username], :password => params[:password])
  
  redirect('/')
end

class User
  include DataMapper::Resource

  property :user_id,        Serial
  property :username,       String
  property :password,       String
  property :fname,          String
  property :lname,          String
end