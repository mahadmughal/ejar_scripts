#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_6654_fetch_sec_request_details_using_contract_number: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      contract_numbers = [
        '10237662645',
        '10868166215',
      ]

      request_numbers = []

      contract_numbers.each do |contract_number|
        request = request_repository.find_by(
          { contract_number: contract_number, status: ['pending', 'waiting_parties', 'to_be_transferred'] }
        )
        if request.present?
          puts "********* request: #{request.request_number} *********"
          request_numbers << { contract_id: request.contract_id, request_number: request.request_number}
        end
      end

      puts "********* request details to trigger move-in: *********"
      pp request_numbers
    end; 0
  end
end; 0

# end move in & move out
