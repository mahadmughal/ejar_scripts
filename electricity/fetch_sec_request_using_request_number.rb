#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_3544_fetch_sec_request_using_request_number: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      request_numbers = [
        "F3BDE6B2GRPW"
      ]

      request_numbers.each do |request_number|
        request = request_repository.find_by(
          { request_number: request_number }
        )
        if request.present?
          puts "********* request: #{request_number} *********"
          pp request
        end
      end
    end; 0
  end
end; 0

# end move in & move out
