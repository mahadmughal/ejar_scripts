#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_4691_validate_account_no: :environment do
    EFrame.db_adapter.with_client do
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)

      account_numbers = [
        '30014433616'
      ]

      SUCCESS_CODES = %w[S N 2]

      account_numbers.each do |account_number|
        puts "********* whose turn: #{account_number} *********"
        begin
          params = { ContractAccount: account_number }
          external_call = ExternalCalls.service.call(
            "SEC.AccountCheck",
            params: params,
            priority: ExternalCalls::Model::Call::PRIORITY_SYNC
          )

          call_id = external_call._id.is_a?(String) ? external_call._id : external_call._id["$oid"]
          payload = external_call&.payload
          account_check_response = payload.dig('Body', 'EJARAccountCheckResponse')
          result = account_check_response['Result']
          success = SUCCESS_CODES.include?(result['MessageCode'].to_s.first)

          sec_response = account_check_response&.dig('EJARAccountCheck')&.first || {}

          puts "********* sec_response: *********"
          pp sec_response

          id = account_number.start_with?('0') && account_number.length == 12 ? account_number[1..-1] : account_number
          premise_id = sec_response.dig('PremiseID')&.to_s
          # id = sec_response.dig('ContractAccount').start_with?('0') && sec_response.dig('ContractAccount').length == 12 ? sec_response.dig('ContractAccount')[1..-1] : sec_response.dig('ContractAccount')


          # puts "********* payload: *********"
          # pp payload
          # puts "********* account_check_response: *********"
          # pp account_check_response
          # puts "********* result: *********"
          # pp result
          # puts "********* success: *********"
          # pp success
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end
    end
  end
end