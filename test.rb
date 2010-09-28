# test.rb
require 'rubygems'
require 'sinatra'
get '/' do
  "Welcome to caffine! #{Time.now}"
end