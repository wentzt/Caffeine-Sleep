# test.rb
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'

DataMapper.setup(:default, ENV['DB_URL'])

get '/' do
  @user = User.get(2)
  
  haml :index
end

post '/update' do
  user = User.get(2)
  user.fname = params[:fname]
  user.save
  
  redirect('/')
end

class User
  include DataMapper::Resource

  property :user_id,        Serial
  property :fname,          String
  property :lname,          String
end