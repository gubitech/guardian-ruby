namespace :guardian do
  desc 'Create a initial user'
  task :create_initial_user => :environment do
    if User.count == 0
      User.create!(:username =>'admin', :password => 'admin')
      puts "An initial user has been created with the username 'admin' and password 'admin'."
    else
      puts "The database already has users in it."
    end
  end
end
