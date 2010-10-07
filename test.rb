# test.rb
require 'rubygems'
require 'sinatra'
require 'sequel'

get '/' do
  
  DB = Sequel.connect(ENV['DB_URL'])
  
  ds = DB[:users]
  @ds2 = ds.first(:user_id => 1)
  
  haml :index
end