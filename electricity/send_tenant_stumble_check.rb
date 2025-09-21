
#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_2395_send_tenant_stumble_check: :environment do
    EFrame.db_adapter.with_client do
      contract_ids = [
        "cd872a0a-509b-4faa-baf9-53c9142f0470",
        "5680c5e3-c54b-4cf4-9bb7-f9967819d14e"
      ]

      auth_context = EFrame::Iam.system_context

      not_found_contract_ids = []
      success_contract_ids = []
      contracts_with_error = []

      puts "********* CR_VALID_TYPE *********"
      pp ENV['CR_VALID_TYPE']

      contract_ids.each do |contract_id|
        contract = ::App::Model::ContractRepository.new(auth_context).find_by({ contract_id: contract_id })

        pp contract

        if contract.nil?
          puts "********* Contract not found *********"
          not_found_contract_ids << contract_id
          next
        end

        sec_request_service = App::Services::SecRequestService.new(auth_context)

        tenant_check_response, tenant_check_call_id = sec_request_service.send(:send_tenant_stumble_check_to_sec, contract)

        puts "********* Tenant check response *********"
        pp tenant_check_response

        if tenant_check_response['Result']['MessageCode'] == 'S999'
          account_number = tenant_check_response['EJARTenantStumbleCheck']['ContractAccount']
          success_contract_ids << {contract_number: contract.contract_number, contract_id: contract_id, account_number: account_number, error: tenant_check_response['Result']['MessageCode'], error_description: tenant_check_response['Result']['MessageText']}
        else
          contracts_with_error << {contract_number: contract.contract_number, contract_id: contract_id, error: tenant_check_response['Result']['MessageCode'], error_description: tenant_check_response['Result']['MessageText']}
        end
      end

      puts "********* Not found contract ids *********"
      pp not_found_contract_ids

      puts "********* Success contract ids *********"
      pp success_contract_ids

      puts "********* Contracts with error *********"
      pp contracts_with_error
    end
  end
end