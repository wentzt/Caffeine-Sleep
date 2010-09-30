# test.rb
require 'rubygems'
require 'sinatra'
require 'sequel'

get '/' do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'mysql://caffeineadmin:sleep@caffeine-sleep.c13gxsgstw8a.us-east-1.rds.amazonaws.com/caffeine')
  
  #ds = DB[:test]
  #ds2 = ds.filter(:id=>1)
  
  "Welcome to caffine!"
end