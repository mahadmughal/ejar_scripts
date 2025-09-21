#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_4648_update_mi_mo_request: :environment do
    EFrame.db_adapter.with_client do
      account_numbers = [
        '3010040137',
        '30080851293'
      ]

      account_numbers.each do |account_number|
        puts "********* whose turn: #{account_number} *********"
        begin
          
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end
    end
  end
end