# SEC
namespace :custom_tasks do
  desc "Execute my custom script to check move-in eligibility"
  task ES_7720_check_mi_eligible_if_not_contract: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)
      
      # List of contract numbers to process
      contract_info_arr = [
        {:contract_number=>"10831817790",
  :unit_number=>"1132",
  :premise_id=>"4011876740",
  :electricity_meter=>"MMF2120800007766",
  :account_no=>"30135714424"}
      ]
      
      contract_info_arr.each do |contract_info|
        puts "********* Processing contract: #{contract_info[:contract_number]} *********"

        contract_number = contract_info[:contract_number]
        premise_id = contract_info[:premise_id]
        electricity_meter_number = contract_info[:electricity_meter]
        unit_number = contract_info[:unit_number]
        account_no = contract_info[:account_no]
        
        puts "********* Processing unit: #{unit_number} *********"

        begin 
          params = {
            data: {
              attributes: {
                contract_number: contract_number,
                premise_id: premise_id,
                electricity_current_reading: electricity_meter_number,
                meter_reading_date: Time.current,
                unit_number: unit_number,
                account_no: account_no
              }
            }
          }
          
          # Call the service to check move-in eligibility
          result = sec_service.check_mi_eligible(params: params)
          pp result
          
        rescue StandardError => e
          pp "Error processing contract #{contract_number}: #{e.message}"
          # pp e.backtrace.join("\n")
        end
      end
    end; 0
  end
end; 0