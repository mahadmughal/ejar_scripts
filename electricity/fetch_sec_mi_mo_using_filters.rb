namespace :custom_tasks do
  desc "Execute my custom script with clean output"
  task ES_626_print_sec_mi_mo: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      
      contract_numbers = [
        "10537311784",
      ]
      
      # Initialize result arrays
      contracts_not_found = []
      contracts_still_active = []
      contracts_mi_successed = []
      contracts_mo_successed = []
      contracts_dont_have_mi_requests = []
      contracts_dont_have_mo_requests = []
      contracts_dont_have_mi_external_call = []
      contracts_dont_have_mo_external_call = []
      contracts_have_mi_request_diff_mi_external_count = []
      contracts_have_mo_request_diff_mo_external_count = []
      contracts_have_mi_exteral_call_error = {}
      contracts_have_mo_exteral_call_error = {}
      
      # Array to store structured request information
      request_info = []

      contract_numbers.each do |contract_number|
        puts "----------------Show contract info for #{contract_number}---------------------"

        contracts = contract_repository.index(
          filters: { contract_number: contract_number },
          page: 1,
          items_per_page: 10
        )

        unless contracts.present?
          contracts_not_found << contract_number
          request_info << {
            contract_number: contract_number,
            status: "not_found",
            mi_request: nil,
            mo_request: nil
          }
          next
        end
        
        # No filtering for active contracts
        contracts.each do |contract|
          if contract.state == "active"
            contracts_still_active << "Contract #{contract_number} - Active - start_date: #{contract.contract_start_date} end_date: #{contract.contract_end_date}"
          end
        end

        # Get Move-in requests
        mi_requests = request_repository.index(
          filters: {
            contract_number: contract_number,
            request_type: 'move_in'
          },
          page: 1,
          items_per_page: 10,
          sort: { created_at: -1 }
        )

        # Get Move-in external calls
        mi_external_call = external_call_repository.index(
          filters: {
            'parameters.EJARMoveInRequest.EJARContractNumber': contract_number
          },
          items_per_page: 10,
          page: 1,
          sort: { created_at: -1 }
        )
        
        e_mi_external_call = external_call_repository.index(
          filters: {
            'parameters.EJARMoveInRequest.eJARContractNumber': contract_number
          },
          items_per_page: 10,
          page: 1,
          sort: { created_at: -1 }
        )

        mo_requests = []
        mo_external_call = []
        e_mo_external_call = []
        
        if mi_external_call.present? || e_mi_external_call.present?
          # Get Move-out requests
          mo_requests = request_repository.index(
            filters: {
              contract_number: contract_number,
              request_type: 'move_out'
            },
            page: 1,
            items_per_page: 10,
            sort: { created_at: -1 }
          )
          
          # Get Move-out external calls
          mo_external_call = external_call_repository.index(
            filters: {
              'parameters.EJARMoveOutRequest.EJARContractNumber': contract_number
            },
            items_per_page: 10,
            page: 1,
            sort: { created_at: -1 }
          )
          
          e_mo_external_call = external_call_repository.index(
            filters: {
              'parameters.EJARMoveOutRequest.eJARContractNumber': contract_number
            },
            items_per_page: 10,
            page: 1,
            sort: { created_at: -1 }
          )
        end

        # Check for missing requests or external calls
        contracts_dont_have_mi_requests << contract_number if mi_requests.blank?
        contracts_dont_have_mi_external_call << contract_number if mi_requests.present? && mi_external_call.blank? && e_mi_external_call.blank?
        contracts_dont_have_mo_requests << contract_number if mo_requests.blank? && mi_requests.present?
        contracts_dont_have_mo_external_call << contract_number if mo_requests.present? && mo_external_call.blank? && e_mo_external_call.blank?

        # Check for count mismatches
        if mi_requests.present? && mi_external_call.present? && mi_requests.size != mi_external_call.size
          contracts_have_mi_request_diff_mi_external_count << contract_number
        end
        if mo_requests.present? && mo_external_call.present? && mo_requests.size != mo_external_call.size
          contracts_have_mo_request_diff_mo_external_count << contract_number
        end

        # Process MI external calls
        mi_success = false
        mi_error_code = nil
        
        (mi_external_call + e_mi_external_call).each do |mi_external_call_item|
          next if mi_external_call_item.try(:payload).blank?
          
          message_code = mi_external_call_item.payload&.dig("EJARMoveInResponse", "EJARMoveInResponse", "Result", "MessageCode") ||
                        mi_external_call_item.payload&.dig("EJARMoveInResponse", "Result", "MessageCode")
          
          if message_code&.to_s&.start_with?("E")
            mi_error_code = message_code
            if contracts_have_mi_exteral_call_error[message_code].present?
              contracts_have_mi_exteral_call_error[message_code] << contract_number
            else
              contracts_have_mi_exteral_call_error[message_code] = [contract_number]
            end
          else
            mi_success = true
            contracts_mi_successed << "Contract: #{contract_number} - Move In request processed successfully"
          end
        end

        # Process MO external calls
        mo_success = false
        mo_error_code = nil
        
        (mo_external_call + e_mo_external_call).each do |mo_external_call_item|
          next if mo_external_call_item.try(:payload).blank?
          
          message_code = mo_external_call_item.payload&.dig("EJARMoveOutResponse", "Result", "MessageCode")
          
          if message_code&.to_s&.start_with?("E")
            mo_error_code = message_code
            if contracts_have_mo_exteral_call_error[message_code].present?
              contracts_have_mo_exteral_call_error[message_code] << contract_number
            else
              contracts_have_mo_exteral_call_error[message_code] = [contract_number]
            end
          else
            mo_success = true
            contracts_mo_successed << "Contract: #{contract_number} - Move Out request processed successfully at #{mo_external_call_item&.created_at}"
          end
        end

        # Store request information for final output
        contract_info = {
          contract_number: contract_number,
          status: contracts.first&.state || "unknown",
          mi_request: mi_requests.first ? {
            sec_reference_number: mi_requests.first.sec_reference_number,
            sec_status: mi_requests.first.sec_status,
            success: mi_success,
            error_code: mi_error_code
          } : nil,
          mo_request: mo_requests.first ? {
            sec_reference_number: mo_requests.first.sec_reference_number,
            sec_status: mo_requests.first.sec_status,
            success: mo_success,
            error_code: mo_error_code
          } : nil
        }
        
        request_info << contract_info
      end

      # Final output of all results
      puts "\n===================== SEC MI/MO REQUESTS SUMMARY ====================="
      puts "Total contracts processed: #{contract_numbers.size}"
      puts "Contracts not found: #{contracts_not_found.size}"
      puts "Contracts still active: #{contracts_still_active.size}"
      puts "\n===================== REQUESTS INFORMATION ====================="
      
      request_info.each do |info|
        puts "\nContract: #{info[:contract_number]} (Status: #{info[:status]})"
        
        if info[:mi_request]
          puts "  Move-In Request:"
          puts "    Unit Number: #{info[:mi_request][:unit_number]}" if info[:mi_request] && info[:mi_request][:unit_number]
          puts "    Request Number: #{info[:mi_request][:request_number]}"
          puts "    SEC Reference: #{info[:mi_request][:sec_reference_number]}"
          puts "    SEC Status: #{info[:mi_request][:sec_status]}"
          puts "    Success: #{info[:mi_request][:success]}"
          puts "    Error Code: #{info[:mi_request][:error_code]}" if info[:mi_request][:error_code]
        else
          puts "  No Move-In Request"
        end
        
        if info[:mo_request]
          puts "  Move-Out Request:"
          puts "    Unit Number: #{info[:mo_request][:unit_number]}" if info[:mo_request] && info[:mo_request][:unit_number]
          puts "    Request Number: #{info[:mo_request][:request_number]}"
          puts "    SEC Reference: #{info[:mo_request][:sec_reference_number]}"
          puts "    SEC Status: #{info[:mo_request][:sec_status]}"
          puts "    Success: #{info[:mo_request][:success]}"
          puts "    Error Code: #{info[:mo_request][:error_code]}" if info[:mo_request][:error_code]
        else
          puts "  No Move-Out Request"
        end
      end
      
      puts "\n===================== ERROR SUMMARY ====================="
      puts "\nMove-In Error Codes:"
      contracts_have_mi_exteral_call_error.each do |error_code, contracts|
        puts "  #{error_code}: #{contracts.size} contracts affected"
      end
      
      puts "\nMove-Out Error Codes:"
      contracts_have_mo_exteral_call_error.each do |error_code, contracts|
        puts "  #{error_code}: #{contracts.size} contracts affected"
      end
    end; 0
  end
end; 0