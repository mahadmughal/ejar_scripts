# SEC
namespace :custom_tasks do
  desc "Execute my custom script to check move-in eligibility"
  task ES_7486_fetch_contract_info_only: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecServiceBase.new(EFrame::Iam.system_context)
      
      contract_numbers = [
        '10407415203',
      ]

      contract_numbers.each do |contract_number|
        contracts = contract_repository.index(
          filters: { contract_number: contract_number },
          page: 1,
          items_per_page: 10
        )

        puts "**************** Contracts info **************"
        pp contracts
      end
    end
  end
end