require 'data_mapper'

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/aisim.db")

# table User
class User
	include DataMapper::Resource
	
	# Table fields
	#property :id, Serial
  #property :name, String
	#...
	
	# Associations
	#has n,	:appointment
end

# table Appointment
class Appointment
	include DataMapper::Resource
	
	# Table fields
	#property :id, Serial
  #property :body, Text
	#...
	
	# Associations
	#has n,	:user
	#belongs_to	:user
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Appointment.auto_upgrade!

# read http://datamapper.org/getting-started.html complete information