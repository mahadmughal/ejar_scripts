#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_1766_delete_sec_mi_mo: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      request_numbers = [
        'S3JV7CAY6CRW',
      ]

      request_numbers.each do |request_number|
        request = request_repository.find_by(
          { request_number: request_number }
        )
        if request.present?
          request_repository.delete(request.id)
          puts "Deleted request: #{request_number}"
        end
      end
    end; 0
  end
end; 0

# end move in & move out
