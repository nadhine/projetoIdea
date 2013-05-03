require 'sinatra'
require 'koala'
require './models'

enable :sessions
set :raise_errors, false
set :show_exceptions, false

# Scope defines what permissions that we are asking the user to grant.
# In this example, we are asking for the ability to publish stories
# about using the app, access to what the user likes, and to be able
# to use their pictures.  You should rewrite this scope with whatever
# permissions your app needs.
# See https://developers.facebook.com/docs/reference/api/permissions/
# for a full list of permissions
FACEBOOK_SCOPE = ''
DISPLAY_LIMIT = 5
DISPLAY_OFFSET = 0

unless ENV["FACEBOOK_APP_ID"] && ENV["FACEBOOK_SECRET"]
  abort("missing env vars: please set FACEBOOK_APP_ID and FACEBOOK_SECRET with your app credentials")
end

before do
  # HTTPS redirect
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
end

helpers do
  def host
    request.env['HTTP_HOST']
  end

  def scheme
    request.scheme
  end

  def url_no_scheme(path = '')
    "//#{host}#{path}"
  end

  def url(path = '')
    "#{scheme}://#{host}#{path}"
  end

  def authenticator
    @authenticator ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], url("/auth/facebook/callback"))
  end

  # allow for javascript authentication
  def access_token_from_cookie
    authenticator.get_user_info_from_cookies(request.cookies)['access_token']
  rescue => err
    warn err.message
  end

  def access_token
    session[:access_token] || access_token_from_cookie
  end
	
	def load_params
		# Get base API Connection
		@graph = Koala::Facebook::API.new(access_token)

		# Get public details of current application
		@app = @graph.get_object(ENV["FACEBOOK_APP_ID"])
	end
	
	def load_user_params(params = [])
		load_params
		if access_token
			@user = @graph.get_object("me")
			params.each do |param|
				eval("@#{param} = #{@graph.get_connections('me', param)}")
			end
		end
	end

end

# the facebook session expired! reset ours and restart the process
error(Koala::Facebook::APIError) do
  session[:access_token] = nil
  redirect "/auth/facebook"
end

get "/" do
	DISPLAY_OFFSET = 0
	load_user_params
	@appointments = Appointment.all(:limit => DISPLAY_LIMIT, :order => [:created_at.desc])
  erb :index
end

get "/loadmore" do
	DISPLAY_OFFSET += DISPLAY_LIMIT
	@appointments = Appointment.all(:limit => DISPLAY_LIMIT, :offset => DISPLAY_OFFSET, :order => [:created_at.desc])
	erb	:loadmore, :layout => false
end

get "/appointment" do
	load_user_params(['friends'])
	erb	:appointment
end

post "/make_appointment" do
	appointment = Appointment.new(
		:idAppoints => params[:appoints],
		:idAppointed => params[:appointed],
		:created_at => Time.now,
		:created_on => Date.today,
		:body => params[:body]
	)
	if appointment.save
		redirect '/'
	else
		redirect '/appointment'
	end
end

# Doesn't actually sign out permanently, but good for testing
get "/logout" do
  session.clear
  session[:authenticated] = false
  redirect "/"
end


# Allows for direct oauth authentication
get "/auth/facebook" do
  session[:access_token] = nil
  redirect authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)
end

get '/auth/facebook/callback' do
  session[:access_token] = authenticator.get_access_token(params[:code])
  redirect '/'
end
