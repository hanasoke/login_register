require 'sqlite3'
require 'bcrypt'

DB = SQLite3::Database.new("users.db")
DB.results_as_hash = true

# Create the users table if it doesn't exist 
DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password_digest TEXT
    );
SQL