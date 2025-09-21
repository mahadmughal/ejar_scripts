#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_7720_trigger_mi_request: :environment do
    EFrame.db_adapter.with_client do
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      
      contracts = [
        {contract_id: "2f4cf946-605e-4baf-a2b3-786ca9538248", request_number: "BC53DKB8C4MV"},
      ]
      
      contracts.each do |contract|
        contract_id = contract[:contract_id]
        request_number = contract[:request_number]
        
        contract = contract_repository.find_by({contract_id: contract_id})
      
        if !contract
          puts "Contract not found: #{contract_id}"
          next  # Changed from 'return' to 'next'
        end
        
        # Get all move_in requests for this contract and these request numbers
        sec_request = request_repository.find_by!({
          contract_id: contract_id,
          request_type: 'move_in',
          status: ['pending', 'to_be_transferred', 'waiting_parties'],
          request_number: request_number
        })
        
        puts "Found matching request"

        if sec_request.present?
          begin
            puts "Processing request: #{sec_request.request_number}"
            # Update to 'to_be_transferred' status if needed
            if sec_request.status != 'to_be_transferred'
              request_repository.update!(sec_request._id, {
                status: 'to_be_transferred',
                updated_at: Time.current
              })
              puts "Updated request #{sec_request.request_number} to to_be_transferred status"
              
              # Reload the request to get the updated status
              sec_request = request_repository.find_by!({ _id: sec_request._id })
            end
            
            # Validate the move-in request
            begin
              App::Services::Validation::MoveInValidation.validate(
                request_number: sec_request.request_number
              )
            rescue => e
              puts "Validation failed for #{sec_request.request_number}: #{e.message}"
              next
            end
            
            # Use send to call the private method
            move_in_response, move_in_call_id = sec_service.send(:send_move_in_request_to_sec, sec_request, contract)
            
            if move_in_call_id.blank? || move_in_response.dig('EJARMoveInResponse', 'ReferenceNumber').blank?
              puts "Failed to get move_in response for #{sec_request.request_number}"
              next
            end
            
            # Update the request status
            request_repository.update!(sec_request._id, {
              status: 'transferred',
              move_in_call_id: move_in_call_id,
              sec_reference_number: move_in_response.dig('EJARMoveInResponse', 'ReferenceNumber'),
              updated_at: Time.current,
              approved_at: Time.current,
              move_in_date: Time.current,
              sec_status: 'Completed'
            })
            
            puts "Successfully processed request: #{sec_request.request_number}"
            
            # Use send to call other private methods as needed
            # sec_service.send(:notify_tenant_enter_meter, sec_request, contract)
            
            # If reflect_meter_number_to_core is also private
            sec_service.send(:reflect_meter_number_to_core, sec_request: sec_request, target: 'contract')
            
          rescue => e
            puts "Error processing request #{sec_request.request_number} with contract number #{contract.contract_number}: #{e.message}"
            # puts e.backtrace.join("\n")
            ::Sentry.set_extras(
              contract_id: contract_id,
              request_number: sec_request.request_number,
              error_from: 'ES_4185_trigger_mi_request'
            )
            ::Sentry.capture_exception(e)
          end
        end
      end
    end
  end
end  # <-- This 'end' was missing to close the namespace block