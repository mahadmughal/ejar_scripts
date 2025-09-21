#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_7486_initiate_mo_request: :environment do
    EFrame.db_adapter.with_client do
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)

      contract_ids = [
          "efbda971-cd8c-4a85-9f45-98d864ac0900",
      ]

      contract_ids.each do |contract_id|
        puts "********* whose turn: #{contract_id} *********"
        begin
          contract = contract_repository.find_by(
            {
              contract_id: contract_id
            }
          )

          puts "********* contract: *********"
          pp contract

          params = {
            event: {
              resource_id: contract_id,
              state: 'registered'
            }
          }

          sec_service.initiate_move_out(params: params)
          puts "********* request updated successfully *********"
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end
    end; 0
  end
end; 0

# end move in & move out
