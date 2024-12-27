require 'sinatra'
require 'bcrypt'
require_relative 'database_setup'

enable :sessions

# Helper methods
def logged_in?
    session[:user_id] != nil
end

def current_user 
    @current_user ||= DB.execute("SELECT * FROM users WHERE id = ?", [session[:user_id]]).first if logged_in?
end

# Routes 
get '/' do
    if logged_in?
        erb :welcome
    else 
        redirect '/login'
    end
end

# Registration
get '/register' do
    erb :register 
end

post '/register' do
    username = params[:username]
    password = BCrypt::Password.create(params[:password])

    begin 
        DB.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", [username, password])
        redirect '/login'
    rescue SQLite3::ConstraintException
        @error = "Username already exists"
        erb :register
    end
end

# Login
get '/login' do 
    erb :login
end

post '/login' do
    username = params[:username]
    user = DB.execute("SELECT * FROM users WHERE username = ?", [username]).first

    if user && BCrypt::Password.new(user['password_digest']) == params[:password]
        session[:user_id] = user['id']
        redirect '/'
    else 
        @error = "Invalid username or password"
        erb :login
    end
end

# Logout 
get '/logout' do
    session.clear
    redirect '/login'
end