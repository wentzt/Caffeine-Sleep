class UserGroup
  include DataMapper::Resource

  property :userid, Integer
  property :groupId, Integer
end

class Group
  include DataMapper::Resource

  property :group_id, Serial
  property :name, String
  property :type, String
end

class Product
  include DataMapper::Resource

  property :product_id, Serial
  property :name, String
  property :type, String
  property :mg, Integer
end

class Productivity_Log
  include DataMapper::Resource

  property :productivity_id, Serial
  property :user_id, Integer
  property :level, String
  property :timestamp, DateTime
end

class Caffeine_Log
  include DataMapper::Resource

  property :caffeine_id, Serial
  property :user_id, Integer
  property :product_id, Integer
  property :mg_intake, Integer
  property :time, Integer
  property :timeStamp, DateTime
end

class Sleep_Log
  include DataMapper::Resource

  property :sleep_id, Serial
  property :user_id, Integer
  property :start_time, DateTime
  property :length, Integer
  property :timeStamp, DateTime
end

class User
  include DataMapper::Resource

  property :user_id, Serial
  property :fname, String
  property :lname, String
  property :email, String
  property :username, String
  property :password, String
  property :type, String
  property :time_stamp, DateTime
end
