#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_5594_print_sec_mi_mo: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      contract_numbers = [
        '10985618296'
      ].uniq

      success_mo_cases = []

      pp "----------Total contracts contract_numbers: #{contract_numbers.size}-----"
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

      contract_numbers.each do |contract_number|
        contracts = contract_repository.index(
          filters: { contract_number: contract_number },
          page: 1,
          items_per_page: 10
        )

        pp "----------------Show contract info for #{contract_number}---------------------"
        pp contracts
        pp "----------------End Show contract info for #{contract_number}---------------------"
        unless contracts.present?
          contracts_not_found << contract_number
          next
        end
        active_contract = contracts.detect {|c| c.state == "active"}
        if active_contract
          contracts_still_active << "Contract #{contract_number} - Active - start_date: #{active_contract.contract_start_date} end_date: #{active_contract.contract_end_date}"
        end

        pp "----------------Check Move in Request for #{contract_number}---------------------"

        mi_requests = request_repository.index(
          filters: {
            contract_number:,
            request_type: 'move_in'
          },
          page: 1,
          items_per_page: 10,
          sort: { created_at: -1 }
        )
        pp mi_requests if mi_requests.present?
        pp "----------------END Request in out for #{contract_number}---------------------"
        pp "----------------Check Move in external call for #{contract_number}---EJARContractNumber------------------"
        mi_external_call = external_call_repository.index(
          filters: {
            'parameters.EJARMoveInRequest.EJARContractNumber': contract_number
          },
          items_per_page: 10,
          page: 1,
          sort: { created_at: -1 }
        )
        pp mi_external_call  if mi_external_call.present?
        pp "----------------End external call---EJARContractNumber------"
        pp "----------------Check Move in external call for #{contract_number}---eJARContractNumber------------------"
        e_mi_external_call = external_call_repository.index(
          filters: {
            'parameters.EJARMoveInRequest.eJARContractNumber': contract_number
          },
          items_per_page: 10,
          page: 1,
          sort: { created_at: -1 }
        )
        pp e_mi_external_call if e_mi_external_call.present?
        pp "----------------End external call---eJARContractNumber------"
        pp "----------------END Move in external call for #{contract_number}---------------------"

        mo_requests = []
        mo_external_call = []
        e_mo_external_call = []
        if mi_external_call.present? || e_mi_external_call.present?
          pp "----------------Check Move out Request for #{contract_number}---------------------"
          mo_requests = request_repository.index(
            filters: {
              contract_number:,
              request_type: 'move_out'
            },
            page: 1,
            items_per_page: 10,
            sort: { created_at: -1 }
          )
          pp mo_requests if mo_requests.present?
          pp "----------------END Request Move out for #{contract_number}---------------------"
          pp "----------------Check Move out external call for #{contract_number} - EJARContractNumber---------------------"
          mo_external_call = external_call_repository.index(
            filters: {
              'parameters.EJARMoveOutRequest.EJARContractNumber': contract_number
            },
            items_per_page: 10,
            page: 1,
            sort: { created_at: -1 }
          )
          pp mo_external_call if mo_external_call.present?
          pp "----------------Check Move out external call for #{contract_number} - eJARContractNumber---------------------"
          e_mo_external_call = external_call_repository.index(
            filters: {
              'parameters.EJARMoveOutRequest.eJARContractNumber': contract_number
            },
            items_per_page: 10,
            page: 1,
            sort: { created_at: -1 }
          )
          pp e_mo_external_call if e_mo_external_call.present?
          pp "----------------END Move out external call for #{contract_number}---------------------"
        end

        contracts_dont_have_mi_requests << contract_number if mi_requests.blank?
        contracts_dont_have_mi_external_call << contract_number if mi_requests.present? && mi_external_call.blank? && e_mi_external_call.blank?

        contracts_dont_have_mo_requests << contract_number if mo_requests.blank? && mi_requests.present?
        contracts_dont_have_mo_external_call << contract_number if mo_requests.present? && mo_external_call.blank?

        if mi_requests.present? && mi_external_call.present? && mi_requests.size != mi_external_call.size
          contracts_have_mi_request_diff_mi_external_count << contract_number
        end
        if mo_requests.present? && mo_external_call.present? && mo_requests.size != mo_external_call.size
          contracts_have_mo_request_diff_mo_external_count << contract_number
        end

        mi_external_call.each do |mi_external_call_item|
          if mi_external_call_item.try(:payload).blank?
            pp "mi_external_call_item----------------"
            pp mi_external_call_item
            pp "end mi_external_call_item"
            next
          end
          message_code = mi_external_call_item.payload&.dig("EJARMoveInResponse", "EJARMoveInResponse", "Result", "MessageCode")
          if message_code&.to_s&.start_with?("E")
            if contracts_have_mi_exteral_call_error[message_code].present?
              contracts_have_mi_exteral_call_error[message_code] << contract_number
            else
              contracts_have_mi_exteral_call_error[message_code] = [contract_number]
            end
          else
            contracts_mi_successed << "Contract: #{contract_number} - Move In request processed successfully"
          end
        end

        ###### MO printing
        mo_external_call.each do |mo_external_call_item|
          if mo_external_call_item.try(:payload).blank?
            pp "mo_external_call_item----------------"
            pp mo_external_call_item
            pp "end mo_external_call_item"
            next
          end
          message_code = mo_external_call_item.payload&.dig("EJARMoveOutResponse", "Result", "MessageCode")
          if message_code&.to_s&.start_with?("E")
            if contracts_have_mo_exteral_call_error[message_code].present?
              contracts_have_mo_exteral_call_error[message_code] << contract_number
            else
              contracts_have_mo_exteral_call_error[message_code] = [contract_number]
            end
          else
            contracts_mo_successed << [contract_number, mo_external_call_item.payload&.dig("EJARMoveOutResponse", "EJARMoveOutResponse", "ReferenceNumber")]
          end
        end

        e_mo_external_call.each do |mo_external_call_item|
          if mo_external_call_item.try(:payload).blank?
            pp "mo_external_call_item----------------"
            pp mo_external_call_item
            pp "end mo_external_call_item"
            next
          end
          message_code = mo_external_call_item.payload&.dig("EJARMoveOutResponse", "Result", "MessageCode")
          if message_code&.to_s&.start_with?("E")
            if contracts_have_mo_exteral_call_error[message_code].present?
              contracts_have_mo_exteral_call_error[message_code] << contract_number
            else
              contracts_have_mo_exteral_call_error[message_code] = [contract_number]
            end
          else
            contracts_mo_successed << [contract_number, mo_external_call_item.payload&.dig("EJARMoveOutResponse", "EJARMoveOutResponse", "ReferenceNumber")]
          end
        end
        ###### END MO printing

        if mi_requests.size > 0 && mi_requests.size == mi_external_call.size && mi_requests.all? do |mi_request|
            mi_request.sec_status == "Completed"
          end && mi_external_call.any? do |mi_call|
                    mi_call.payload&.dig("EJARMoveInResponse", "Result",
                                        "MessageCode")&.to_s&.start_with?("N")
                  end
          contracts_mi_successed << contract_number
        end

        # next unless mo_requests.size > 0 && mo_requests.size == mo_external_call.size && mo_requests.all? do |mo_request|
        #               mo_request.sec_status == "Completed"
        #             end && mo_external_call.any? do |mo_call|
        #                      mo_call.payload&.dig("EJARMoveOutResponse", "Result",
        #                                          "MessageCode")&.to_s&.start_with?("N")
        #                    end

        # contracts_mo_successed << contract_number
      end

      # pp "------------contracts_no_mi_requests_no_mo_requests-------"
      # pp contracts_no_mi_requests_no_mo_requests
      pp "----contract_numbers. Count : #{contract_numbers.count}"
      pp "------------contracts_not_found-------"
      pp contracts_not_found
      pp "------------contracts_dont_have_mi_requests-------"
      pp contracts_dont_have_mi_requests
      pp "------------contracts_dont_have_mi_external_call-------"
      pp contracts_dont_have_mi_external_call
      pp "------------contracts_dont_have_mo_requests-------"
      pp contracts_dont_have_mo_requests
      pp "------------contracts_dont_have_mo_external_call-------"
      pp contracts_dont_have_mo_external_call
      pp "------------contracts_have_mi_request_diff_mi_external_count-------"
      pp contracts_have_mi_request_diff_mi_external_count
      pp "------------contracts_have_mo_request_diff_mo_external_count-------"
      pp contracts_have_mo_request_diff_mo_external_count
      pp "------------contracts_have_mi_exteral_call_error-------"
      pp contracts_have_mi_exteral_call_error
      pp "------------contracts_have_mo_exteral_call_error-------"
      pp contracts_have_mo_exteral_call_error
      pp "------------contracts_mi_successed---------"
      pp contracts_mi_successed
      pp "------------contracts_mo_successed-----Count: #{contracts_mo_successed.count}----"
      pp contracts_mo_successed
      pp "------------contracts_still_active---------Count: #{contracts_still_active.count} ---"
      pp contracts_still_active.compact
      pp "------------final success_mo_cases---------Count: #{success_mo_cases.count} ---"
      pp success_mo_cases
    end; 0
  end
end; 0

# end move in & move out