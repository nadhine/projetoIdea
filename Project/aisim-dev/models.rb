require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/aisim.db")

# table User
class User
	include DataMapper::Resource
	
	# Table fields
	property :id, Integer, :key => true
  property :name, String, :required => true
	
	has n, :appointments, :child_key => [ :source_id ]
	has n, :appointeds, self, :through => :appointments, :via => :target
end

# table Appointment
class Appointment
	include DataMapper::Resource
	
	# Table fields
  property :date, Date
	property :time, Time
	property :body, Text
	
	# Associations
	belongs_to :appoints, 'User', :key => true
  belongs_to :appointed, 'User', :key => true
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the Appointment table
Appointment.auto_upgrade!

# read http://datamapper.org/getting-started.html complete information