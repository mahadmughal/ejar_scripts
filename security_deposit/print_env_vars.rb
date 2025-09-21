# namespace :custom_tasks do
#   desc "ES_2222_print_env_vars"
#   task ES_2222_print_env_vars: :environment do
#     # EFrame.db_adapter.with_client do
#       puts "SIDEKIQ_USERNAME: #{ENV['SIDEKIQ_USERNAME']}"
#       puts "SIDEKIQ_PASSWORD: #{ENV['SIDEKIQ_PASSWORD']}"
#     # end
#   end
# end


puts ENV['SIDEKIQ_USERNAME']
puts ENV['SIDEKIQ_PASSWORD']