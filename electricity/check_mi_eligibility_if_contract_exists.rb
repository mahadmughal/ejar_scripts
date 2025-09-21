# SEC
namespace :custom_tasks do
  desc "Execute my custom script to check move-in eligibility"
  task ES_2482_check_mi_eligible: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)
      

      # List of contract IDs to process
      contract_info_arr = [
        {contract_id: 'cc0767a7-5559-4644-81f2-0e6430af2284', premise_id: '4000754856', electricity_meter_number: 'KFM2020860435728', unit_number: '7'},
        {contract_id: 'd3c35b27-a707-41f0-b8f6-9941dfc0d2e7', premise_id: '4003755160', electricity_meter_number: 'SMR2020856027629', unit_number: '5003'},
      ]
      
      contract_info_arr.each do |contract_info|
        puts "********* Processing contract: #{contract_info[:contract_id]} *********"

        contract_id = contract_info[:contract_id]
        premise_id = contract_info[:premise_id]
        electricity_meter_number = contract_info[:electricity_meter_number]
        unit_number = contract_info[:unit_number]
        
        begin
          # Fetch contract details from the repository
          contract = contract_repository.find_by(
            {
              contract_id: contract_id
            })

          puts "Contract: #{contract}"
          
          # Skip if contract not found
          unless contract
            puts "Contract not found: #{contract_id}"
            next
          end
          
          # Extract required information from the contract
          contract_number = contract.contract_number

          puts "Contract number: #{contract_number}"

          # Process each unit service from the contract
          params = {
            data: {
              attributes: {
                contract_number: contract_number,
                premise_id: premise_id,
                electricity_current_reading: electricity_meter_number,
                meter_reading_date: Time.current,
                unit_number: unit_number
              }
            }
          }

          puts "********* params: *********"
          pp params
          
          # Call the service to check move-in eligibility
          result = sec_service.check_mi_eligible(params: params)
          pp result
          
        rescue StandardError => e
          puts "Error processing contract #{contract_id}: #{e.message}"
          puts e.backtrace.join("\n")
        end
      end
    end; 0
  end
end; 0