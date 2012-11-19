namespace :automation do
  desc "Create an admin user to test with and set it's API token to the given value"
  task :create_admin_user, [:api_token] => :environment do |t, args|
    [{api_token: token},{email: "testbed@truestack.com"}].each do |key|
      user = User.where(key)
      if (user)
        puts "Destroying old user"
        user.destroy
      end
    end
    user = User.create({email: "testbed@truestack.com", password: "123456", password_confirmation: "123456"}.merge(args))
    user.save!
    puts "User created: "
    puts user.attributes.to_yaml
  end
end
