# lib/tasks/seed_production.rake
namespace :db do
  desc "Seed the production database with sample data"
  task seed_production: :environment do
    if Rails.env.production?
      puts "Running seeds in PRODUCTION environment..."
      load Rails.root.join("db/seeds.rb")
      puts "Seed data loaded successfully!"
    else
      puts "This task is intended for the production environment only."
      puts "Current environment: #{Rails.env}"
      puts "To run in another environment, use: RAILS_ENV=production rake db:seed_production"
    end
  end
end
