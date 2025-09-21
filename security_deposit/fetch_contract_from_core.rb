namespace :custom_tasks do
  desc "ES_5931_fetch_contract_from_core"
  task ES_5931_fetch_contract_from_core: :environment do
    contract_service = App::Services::ContractService.new(EFrame::Iam.system_context)

    contract_numbers = [
      'b5e47fb7-8d75-471f-88ae-784d820e4912',
    ]

    contract_numbers.each do |contract_number|
      # contract = Ejar3::Api.contract.latest_contract_details(contract_number, 'e3security')

      # params = contract_service.expose_contract_data(new_contract_id, old_contract_id)

      # puts "************* Contract ***********"
      # pp contract

      contract = Ejar3::Api.contract.contract_details(contract_number, 'e3security')
      pp contract.contract_number
    end
  end
end