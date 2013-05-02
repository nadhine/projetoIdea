require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/aisim.db")

# table Appointment
class Appointment
	include DataMapper::Resource
	
	# Table fields
	property :idAppoints, Integer, :key => true
	property :idAppointed, Integer, :key => true
  property :created_at, DateTime, :key => true
	property :created_on, Date
	property :body, Text
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the Appointment table
Appointment.auto_upgrade!

# read http://datamapper.org/getting-started.html for more information