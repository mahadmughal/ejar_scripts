namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_627_cancel_unneeded_sec_mi_mo: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      contract_numbers = [
        '10813041221',
        '10700432895',
      ]
      
      contract_numbers.each do |contract_number|
        contracts = contract_repository.index(
          filters: { contract_number: contract_number },
          page: 1,
          items_per_page: 10
        )
        
        unless contracts.present?
          puts "Contracts not found for contract number: #{contract_number}"
          next
        end
        
        unless contracts.count == 1
          puts "Contract has multiple versions: #{contract_number}"
          next
        end
        
        contract = contracts.first
        
        contract.contract_unit_services.each do |unit_service|
          puts "Processing unit service: #{unit_service}"

          unit_number = unit_service["unit_number"]

          if unit_service["service_type"] == "electricity"

            # Handle Move-In requests
            mi_requests = request_repository.index(
              filters: {
                contract_id: contract.contract_id,
                request_type: 'move_in',
                unit_number: unit_number
              },
              page: 1,
              items_per_page: 10
            )

            if mi_requests.blank?
              puts "No MI requests found for contract_number: #{contract_number}"
            else
              puts "Found #{mi_requests.count} MI requests for contract_number: #{contract_number}"
              
              # Find MI request with SEC reference number
              mi_with_sec = mi_requests.find { |req| req.sec_reference_number.present? }
              
              if mi_with_sec
                puts "Found MI request with SEC reference number: #{mi_with_sec.sec_reference_number}"
                
                # Cancel all other MI requests
                mi_requests.each do |req|
                  next if req.request_number == mi_with_sec.request_number # Skip the one with SEC reference
                  
                  begin
                    puts "Cancelling MI request ID: #{req.id}"
                    request_repository.update!(
                      req.id,
                      { status: 'canceled', updated_at: Time.current}
                    )
                    puts "Successfully cancelled MI request ID: #{req.id}"
                  rescue => e
                    puts "Error cancelling MI request ID: #{req.id}: #{e.message}"
                  end
                end
              else
                puts "No MI request with SEC reference number found for contract_number: #{contract_number}"
              end
            end

            # Handle Move-Out requests
            mo_requests = request_repository.index(
              filters: {
                contract_id: contract.contract_id,
                request_type: 'move_out',
                unit_number: unit_number
              },
              page: 1,
              items_per_page: 10
            )

            if mo_requests.blank?
              puts "No MO requests found for contract_number: #{contract_number}"
            else
              puts "Found #{mo_requests.count} MO requests for contract_number: #{contract_number}"
              
              # Find MO request with SEC reference number
              mo_with_sec = mo_requests.find { |req| req.sec_reference_number.present? }
              
              if mo_with_sec
                puts "Found MO request with SEC reference number: #{mo_with_sec.sec_reference_number}"
                
                # Cancel all other MO requests
                mo_requests.each do |req|
                  next if req.request_number == mo_with_sec.request_number # Skip the one with SEC reference
                  
                  begin
                    puts "Cancelling MO request ID: #{req.request_number}"
    
                    request_repository.update!(
                      req.id,
                      { status: 'canceled', updated_at: Time.current}
                    )
    
                    puts "Successfully cancelled MO request ID: #{req.id}"
                  rescue => e
                    puts "Error cancelling MO request ID: #{req.id}: #{e.message}"
                  end
                end
              else
                puts "No MO request with SEC reference number found for contract_number: #{contract_number}"
              end
            end
          end
        end
        
        puts "Processing completed for contract_number: #{contract_number}"
        puts "-------------------------------------------------"
      end
      
      puts "Script execution completed!"
    end
  end
end