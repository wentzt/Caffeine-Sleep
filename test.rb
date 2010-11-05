# test.rb
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'
require 'sass'
require 'gruff'


DataMapper.setup(:default, ENV['DB_URL'])

require 'models'

enable :sessions

SecsPerDay = 24 * 60 * 60

get '/' do
  
  @greeting = "Not logged in."
  if session[:user_id] then
    user = User.get(session[:user_id])
    @greeting = "Welcome, " + user.fname + " " + user.lname
  end
    
  
  haml :index
end

get '/productivityGraph' do
  past24Hrs = Time.now - SecsPerDay
  user = User.get(session[:user_id])

  caffeineEntries = Caffeine_Log.all(:user => user)
  caffeineAmts = Array.new
  caffeineEntries.each do |caffEntry|
    logTime = caffEntry.timestamp
    caffTime = Time.parse("#{caffEntry.time} #{logTime.day}-#{logTime.month}-#{logTime.year}")
    if caffTime >= past24Hrs
      caffeineAmts[caffEntry.time] = caffEntry.mg
    end
  end

  productivityEntries = Productivity_Log.all(:timestamp.gte => past24Hrs, :user => user)
  productivityLevels = Array.new
  productivityEntries.each do |prodEntry|
    productivityLevels[prodEntry.timestamp.hour]  = prodEntry.level
  end


  sleepEntries = repository(:default).adapter.select('SELECT * FROM sleep_logs WHERE start_time >= ? AND user_id = ?', past24Hrs, user.id)
  sleepAmts = Array.new
  sleepEntries.each do |sleepEntry|
    sleepAmts[sleepEntry.start_time.hour] = sleepEntry.length
  end

  g = Gruff::Line.new 780
  g.title = "Past 24 Hrs of Productivity"
  g.data("productivity", productivityLevels)
  g.data("caffeine", caffeineAmts)
  g.data("sleep", sleepAmts)
  g.labels = {0 => "12 am", 12 => "12 pm", 23 => "11 pm"}
  g.write('public/graphs/productivityGraph.png')
  haml :graph
end

get '/register' do
  haml :register
end

get '/products' do
  @products = Product.all
  haml :products
end

get '/product:productId' do |id|
  @product=Product.get(id)
  haml :product
end

get '/addProduct' do
  haml :addProduct
end

post '/addProduct' do
  @product = Product.create(:name => params[:name], :type => params[:type], :mg => params[:mg])
  redirect "/product#{@product.id}"
end

get '/deleteProduct:productId' do |id|
  product = Product.get(id)
  product.destroy
  redirect '/products'
end

get '/groups' do
  @groups = Group.all
  haml :groups
end

get '/group:groupId' do |id|
  @group = Group.get(id)
  haml :group 
end

get '/deleteGroup:groupId' do |id|
  group=Group.get(id)
  group.destroy
  redirect '/groups'
end

get '/addGroup' do
  haml :addGroup
end

post '/addGroup' do
  @group = Group.create(:name => params[:name], :type => params[:type])
  redirect "group#{@group.id}"
end


get '/logsleep' do
  if session[:user_id]
    haml :logsleep
  end
end

post '/logsleep' do
  if session[:user_id]
    user = User.get(session[:user_id])
    @sleepEntry = Sleep_Log.create(:start_time => params[:starttime], :length => params[:length], :user => user)
  end
  "The sleep entry id that you just created is #{@sleepEntry.id} and the length #{@sleepEntry.length} and the start time is #{@sleepEntry.start_time} and you are #{@sleepEntry.user.fname}"
  #redirect 'viewsleep'
end
    
get '/viewsleep' do
  if session[:user_id] 
    user = User.get(session[:user_id])
    #@sleepEntries = Sleep_Log.all
    @sleepEntries = repository(:default).adapter.select('SELECT * FROM sleep_logs WHERE user_id = ?', user.id)
    haml :viewsleep
  end
end

get '/logproductivity' do
  if session[:user_id] then
    haml :logproductivity
  end
end

get '/viewproductivity' do
  if session[:user_id] then
    user = User.get(session[:user_id])
    @productivityEntries = Productivity_Log.all(:user => user)
  end
  haml :viewproductivity
end

post '/logproductivity' do
  if session[:user_id]
    user = User.get(session[:user_id])
    @productivityEntry = Productivity_Log.create(:level => params[:level], :user => user)
  end
  redirect '/viewproductivity'

end

get '/logCaffeine' do
  if session[:user_id]
    @products = Product.all
    haml :logCaffeine
  end
end

post '/logCaffeine' do
  if session[:user_id]
    user = User.get(session[:user_id])
    product = Product.get(params[:product])
    @caffeineEntry = Caffeine_Log.create(:mg => params[:mg], :time => params[:time], :user => user, :product => product)
  end
  "The caffeine id you just created is #{@caffeineEntry.id} and time was #{@caffeineEntry.time} at #{@caffeineEntry.timestamp}"
end

get '/caffeineLogs' do
  if session[:user_id]
    @caffeineEntries = Caffeine_Log.all
    haml :caffeineLogs
  else
    halt "Access Dennied"
  end
end


get '/accountsettings' do
  if session[:user_id]
    @user = User.get(session[:user_id])
  end
  haml :accountsettings
end 

post '/accountsettings' do
  if session[:user_id] then
    user = User.get(session[:user_id])
    user.update(:fname => params[:fname], :lname => params[:lname], :username => params[:username], :password => params[:password], :email => params[:email])
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

get '/login' do
  haml :login
end

get '/logout' do
  session[:user_id] = nil
  
  redirect '/'
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :stylesheet
  
end

helpers do
  def renderPartial(view)
    haml :"#{view}"
  end
end
