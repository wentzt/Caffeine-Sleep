# test.rb
require 'rubygems'
require 'sinatra'
require 'sequel'

get '/' do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'mysql://caffeineadmin:sleep@caffeine-sleep.c13gxsgstw8a.us-east-1.rds.amazonaws.com/caffeine')
  
  ds = DB[:Test]
  ds2 = ds.first(:id => 2)
  
  "Welcome to caffine! #{ds2[:label]}"
end