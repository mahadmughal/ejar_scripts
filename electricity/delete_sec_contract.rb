#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_646_delete_contract: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)

      collection = contract_repository.send(:table)
      result = collection.delete_one(contract_id: 'f8cac515-b68f-4e39-b82b-5b769f2d70ff')
      puts "Deleted contract: #{result}" if result
    end; 0
  end
end; 0