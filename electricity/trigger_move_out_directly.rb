namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_4833_perform_mo_request: :environment do
    EFrame.db_adapter.with_client do
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)

      input_params = [
        {contract_id: '02abcea8-1e70-48a4-b2d7-4129168f2c57', request_number: '6WVZKZAJVH6R'},
      ]
      
      input_params.each do |input_param|
        contract_id = input_param[:contract_id]
        request_number = input_param[:request_number]
        
        puts "********* whose turn: #{request_number} *********"

        begin
          mo_request = request_repository.find_by(
            {
              contract_id: contract_id,
              request_type: 'move_out',
              request_number: request_number
            }
          )
          
          raise "Move out request not found for contract_id: #{contract_id}" unless mo_request.present?
          
          contract = contract_repository.find_by(
            {
              contract_id: contract_id
            }
          )
          
          raise "Contract not found for contract_id: #{contract_id}" unless contract.present?
          
          ::App::Services::MoveOutRequest::Send.new(EFrame::Iam.system_context).call(mo_request, contract)
          puts "********* move_out performed successfully *********"
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end
    end; 0
  end
end; 0