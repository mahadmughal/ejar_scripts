# SEC
namespace :custom_tasks do
  desc "Execute my custom script to check move-in eligibility"
  task ES_5065_fetch_contract_info_from_core: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      contract_factory = App::Services::ContractFactory.new(EFrame::Iam.system_context)

      params_attributes = {
        contract_number: '10183893275',
        unit_number: "OJ-ZC-C866-FL03-U0306",
        premise_id: "4010454520",
        meter_number: "GTR2320890721012",
      }

      contract_number = params_attributes[:contract_number]
      unit_number = params_attributes[:unit_number]

      copied_contract = contract_factory.find_or_create({
        contract_number: contract_number
      })

      contract = Ejar3::Api.contract.fetch_contract_info(contract_number, unit_number, nil)

      puts "************* Contract ***********"
      pp contract

      raise ::App::Services::Sec::Errors::Validation::ContractNotFound unless contract

      attrs = {
        contract_id: contract.id,
        contract_start_date: contract.contract_start_date,
        contract_end_date: contract.contract_end_date,
        contract_number: contract.contract_number,
        version: contract.version,
        state: contract.state,
        is_awqaf: contract.is_awqaf,
        contract_sub_type: contract.contract_sub_type,
        contract_type: contract.contract_type,
        brokerage_office_name: contract.brokerage_office_name,
        brokerage_office_subscription_id: contract.brokerage_office_subscription_id,
        brokerage_office_cr_number: contract.brokerage_office_cr_number,
        property_id: contract.property_id,
        is_conditional_contract: contract.is_conditional_contract,
        parties: contract.parties,
        contract_unit_services: contract.contract_unit_services,
        previous_version_contract_id: contract.previous_version_contract_id,
        is_renewal: contract.is_renewal,
        superseded: contract.superseded,
        updated_at: Time.current,
        brokerage_agreement_information: contract.brokerage_agreement_information,
        portfolio_ownership_document_id: contract.portfolio_ownership_document_id
      }

      puts "************ Attributes ************"
      pp attrs

      contract_repository.update!(
        copied_contract.id,
        attrs
      )

      contract = contract_repository.find_by({
        contract_id: contract.id
      })

      puts "**************** Final Contract ***************"
      pp contract
    end
  end
end