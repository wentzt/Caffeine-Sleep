# test.rb
require 'rubygems'
require 'sinatra'
require 'sequel'

get '/' do
  
  DB = Sequel.connect('mysql://caffeine_sleep:sleep@www.wentzt.net/caffeine_sleep')
  
  ds = DB[:users]
  @ds2 = ds.first(:user_id => 1)
  
  haml :index
end