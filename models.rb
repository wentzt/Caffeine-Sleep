class UserGroup
  include DataMapper::Resource

  belongs_to :user, :key => true
  belongs_to :group, :key => true
end

class Group
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String,   :length => 20, :required => true
  property :type,       String,   :length => 20
  
  has n, :members, :through => :usergroups, :via => :user
end

class Product
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String,   :length => 20, :required => true
  property :type,       String,   :length => 20
  property :mg,         Integer,  :required => true
end

class Productivity_Log
  include DataMapper::Resource

  property :id,         Serial
  property :level,      Integer,  :required => true
  property :timestamp,  DateTime, :writer => :private
  
  belongs_to :user
end

class Caffeine_Log
  include DataMapper::Resource

  property :id,         Serial
  property :mg,         Integer,  :required => true
  property :time,       Integer,  :required => true
  property :timestamp,  DateTime, :writer => :private
  
  belongs_to :user
  belongs_to :product, :required => false
end

class Sleep_Log
  include DataMapper::Resource

  property :id,         Serial
  property :start_time, Time,     :required => true
  property :length,     Integer,  :required => true
  property :timestamp,  DateTime, :writer => :private
  
  belongs_to :user
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :fname,      String,   :length => 50, :required => true
  property :lname,      String,   :length => 50, :required => true
  property :email,      String,   :length => 50, :required => true
  property :username,   String,   :length => 20, :required => true
  property :password,   String,   :length => 20, :required => true
  property :type,       String,   :length => 20
  property :timestamp,  DateTime, :writer => :private
  
  has n, :caffeine_logs
  has n, :productivity_logs
  has n, :sleep_logs
  has n, :groups, :through => :usergroups
end
