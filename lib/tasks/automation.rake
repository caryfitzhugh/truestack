namespace :automation do
  desc "Create an admin user to test with and set it's API token to the given value"
  task :create_admin_user, [:token] => :environment do |t, token|
    user = User.where(api_token: token)
    if (user)
      puts "Destroying old user"
      user.destroy
    end
    user = User.create(email: "testbed@truestack.com", password: "123456", password_confirmation: "123456", api_token: token)
    user.save!
    puts "User created: "
    puts user.attributes.to_yaml
  end
end
