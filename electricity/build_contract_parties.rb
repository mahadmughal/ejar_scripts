# SEC
namespace :custom_tasks do
  desc "Execute my custom script to check move-in eligibility"
  task ES_2018_update_contract_parties: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecServiceBase.new(EFrame::Iam.system_context)
      
      contract_ids = [
        'ee64588f-dbf6-4e75-affb-6275f81fa052',
        '44015799-7c68-43ec-86a6-12e92f646d03'
      ]

      contract_ids.each do |contract_id|
        contract = contract_repository.find_by({
            contract_id: contract_id
        })

        # result = sec_service.build_owner_details(contract)
        result = sec_service.build_tenant_details(contract)

        puts "**************** Contracts Parties info **************"
        pp result
      end
    end
  end
end