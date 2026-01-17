# helper debug runner
# usage: bundle exec rails runner 'load "lib/tasks/debug_tasks.rb"; DebugTasks.check'
module DebugTasks
  def self.check
    puts "DB adapter: #{ActiveRecord::Base.connection.adapter_name}"
    tables = ActiveRecord::Base.connection.tables
    puts "Tables: #{tables.join(', ')}"
    if tables.include?('users')
      puts "Users table exists. Count: #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM users').first[0]}"
      begin
        u = User.first
        puts "First user: #{u.inspect}"
      rescue => e
        puts "Error reading users: #{e.class}: #{e.message}"
      end
    else
      puts "Users table missing"
    end
  end
end
