#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_4781_update_mi_mo_request: :environment do
    EFrame.db_adapter.with_client do
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)

      account_numbers = [
        '30083414809',
        '30083414818'
      ]

      account_numbers.each do |account_number|
        puts "********* whose turn: #{account_number} *********"
        begin
          App::Services::Validation::AccountNoValidation.validate(
              account_no: account_number
            )

          account_check_response, account_check_call_id = sec_service.account_check(account_number)
          premise_id = account_check_response.dig("EJARAccountCheck", "PremiseID").to_s.strip

          puts "********* Account check response ********"
          pp account_check_response
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end
    end
  end
end