class UserGroup
  include DataMapper::Resource

  property :id, Serial
  property :userId, Integer
end

class Group
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :type, String
end

class Product
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :mg, Integer
  property :type, String
end

class Productivity
  include DataMapper::Resource

  property :id, Serial
  property :userId, Integer
  property :level, String
  property :timeStamp, DateTime
end

class CaffeineLog
  include DataMapper::Resource

  property :id, Serial
  property :userId, Integer
  property :productId, Integer
  property :mg, Integer
  property :time, DateTime
  property :timeStamp, DateTime
end

class SleepLog
  include DataMapper::Resource

  property :id, Serial
  property :userId, Integer
  property :startTime, DateTime
  property :length, Integer
  property :timeStamp, DateTime
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :type, String
  property :groupId, Integer
  property :fname, String
  property :lname, String
  property :email, String
  property :password, String
  property :timeStamp, DateTime
end
