#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_4833_update_request_using_sec_and_contract_no: :environment do
    EFrame.db_adapter.with_client do
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)

      contract_details = [
        { contract_number: "10788354206", sec_reference_number: '2011435238'},
        { contract_number: "10209440421", sec_reference_number: '2011435238'},
      ]

      contract_details.each do |contract_detail|
        contract_number = contract_detail[:contract_number]
        sec_reference_number = contract_detail[:sec_reference_number]

        puts "********* whose turn: #{contract_number} *********"
        begin

          contracts = contract_repository.index(
            filters: { contract_number: contract_number },
            page: 1,
            items_per_page: 10
          )

          unless contracts.present?
            puts "Contracts not found for contract number: #{contract_number}"
            next
          end

          contract = contracts.first

          unless contract.contract_unit_services.size == 1
            puts "Contract have multiple units: #{contract_number}"
          end

          requests = request_repository.index(
            filters: {
              contract_id: contract.contract_id,
              request_type: 'move_out',
              # status: ['approved', 'transferred', 'pending', 'waiting_parties', 'to_be_transferred', 'cance']
            },
            page: 1,
            items_per_page: 10
          )

          puts "********* requests found: #{requests.size} *********"
          pp requests

          if requests.present?
            request = requests.first
            request_repository.update!(request._id, {
                move_out_date: Time.current,
                status: 'transferred',
                updated_at: Time.current,
                sec_status: 'Completed',
                # sec_reference_number: sec_reference_number,
            })
            puts "********* request updated successfully *********"
          end

          puts "********** Finish ***********"
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end
    end; 0
  end
end; 0

# end move in & move out


# SEC_STATUSES = {
#         'created' => 'Created',
#         'cancelled' => 'Cancelled',
#         'in_progress' => 'In Progress',
#         'completed' => 'Completed',
#         'rejected' => 'Rejected'
#       }

# pending: 'pending',
# to_be_transferred: 'to_be_transferred',
# waiting_parties: 'waiting_parties',
# transferred: 'transferred',
# rejected: 'rejected',
# approved: 'approved',
# canceled: 'canceled'


# 2024-12-10