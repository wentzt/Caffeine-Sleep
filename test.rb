# test.rb
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'
require 'sass'
#require 'gruff'


DataMapper.setup(:default, ENV['DB_URL'])

require 'models'

enable :sessions

get '/' do
  
  @greeting = "Not logged in."
  if session[:user_id]
    user = User.get(session[:user_id])
    @greeting = "Welcome, " + user.fname + " " + user.lname
  else
    redirect '/login'
  end
    
  haml :index
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
  @error = ""
  if params[:name] == "" || params[:type] == "" || params[:mg] == ""
    @error = "Some fields are missing"
    haml :addProduct

  elsif !isNumber(params[:mg])
    @error = "the amount must be a number."
    haml :addProduct
 
  else
    @product = Product.create(:name => params[:name], :type => params[:type], :mg => params[:mg])
    redirect "/product#{@product.id}"
  end  
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
  @error =""
  haml :addGroup
end

post '/addGroup' do
  if !session[:user_id]
    redirect '/login'
  else
    if params[:name] != "" && params[:type] != ""
      @group = Group.create(:name => params[:name], :type => params[:type])
      redirect '/groups'
      #Sorry Ben.  Something I did broke your really cool get parameter passing thing.  My bad.     
      #redirect "group#{@group.id}"
    else 
      @error = "One or more fields are missing."
      haml :addGroup;
    end
  end
end


get '/logsleep' do
  if session[:user_id]
    haml :logsleep
  end
end

post '/logsleep' do
  @error = ""
  if session[:user_id]
    if params[:starttime] == "" || params[:length] == ""
      @error = "Some fields are missing"
      haml :logsleep
    elsif !(isNumber(params[:length]) && isNumber(params[:starttime]))  
      @error = "start time and length must be numbers"
      haml :logsleep
    else
      user = User.get(session[:user_id])
      @sleepEntry = Sleep_Log.create(:start_time => params[:starttime], :length => params[:length], :user => user)
      "The sleep entry id that you just created is #{@sleepEntry.id} and the length #{@sleepEntry.length} and the start time is #{@sleepEntry.start_time} and you are #{@sleepEntry.user.fname}"
    end
  else
    redirect '/login'
  end
end
    
get '/viewsleep' do
  if session[:user_id] 
    #user = User.get(session[:user_id])
    #@sleepEntries = Sleep_Log.all
    @sleepEntries = repository(:default).adapter.select('SELECT * FROM sleep_logs')
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
  @error = ""
  if session[:user_id]
    user = User.get(session[:user_id])
    if !isNumber(params[:level])
      @error = "The level must be a number"
      haml :logproductivity
    else
      @productivityEntry = Productivity_Log.create(:level => params[:level], :user => user)
      redirect '/viewproductivity'
    end
  else
    redirect '/login'
  end
end

get '/logCaffeine' do
  if session[:user_id]
    @products = Product.all
    haml :logCaffeine
  end
end

post '/logCaffeine' do
  if session[:user_id]
    #"The Time you entered is #{Time.parse(params[:time])}"
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

get 'productivityGraph' do 
  g = Gruff::Line.new
  g.title = "Past 24 Hrs of Productivity"
  g.data("productivity", [])
  g.data("caffeine", [])
  g.data("sleep", [])
  g.labels = {}
  g.write('productivityGraph.png')
end

get '/accountsettings' do
  if session[:user_id]
    @user = User.get(session[:user_id])
  end
  haml :accountsettings
end 

post '/accountsettings' do
  
  #If user is logged in
  if session[:user_id]

    #get the user
    @user = User.get(session[:user_id])

    #If fields are missing, postback an error and the original user data.
    if params[:username] == "" || params[:password] == "" || params[:fname] == "" || params[:lname]== "" || params[:email] == ""
      @error = "One or more fields were missing.  Please try again."

    #Otherwise try to update the user
    else
      @user.update(:fname => params[:fname], :lname => params[:lname], :username => params[:username], :password => params[:password], :email => params[:email])
      @error = "Account successfully updated."
    end

    haml :accountsettings

  else
    redirect '/login'
  end
end

post '/register' do

  #Check to see if the username is taken
  if User.first(:username => params[:username]) != nil
    @error = "The username is already taken."
  
  #Check for missing fields.
  elsif
    params[:username] == "" || params[:password] == "" || params[:fname] == "" || params[:lname]== "" || params[:email] == ""
    @error = "One or more fields are missing."
  
  #Try to create the user.
  else
    @user = User.create(:username => params[:username], :password => params[:password], :fname => params[:fname], :lname => params[:lname], :email => params[:email])
    if @user
      session[:user_id] = @user.id
      redirect '/'
    else
      @error = "An unknown error occured."
    end
  end

  haml :register
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
  #return File.open("views/stylesheet.css")
  #scss :stylesheet
end

helpers do
  def renderPartial(view)
    haml :"#{view}"
  end
end

#Based on code for IsNumeric from 
#http://rosettacode.org/wiki/Determine_if_a_string_is_numeric
def isNumber(s)
  begin
    Float(s)
  rescue
    false # not numeric
  else
    true # numeric
  end
end
