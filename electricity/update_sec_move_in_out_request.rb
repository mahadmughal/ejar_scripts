#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_4733_update_mi_mo_request: :environment do
    EFrame.db_adapter.with_client do
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)

      request_details = [
        {request_number: "UNPKBVGQVDT9", sec_ref_number: '2011497980'},
      ]

      request_details.each do |request_detail|
        request_number = request_detail[:request_number]
        sec_ref_number = request_detail[:sec_ref_number]

        puts "********* whose turn: #{request_number} *********"
        begin
          request = request_repository.find_by!(
            {
              request_number: request_number
            }
          )
          pp request

          request_repository.update!(request._id, {
              # move_out_date: Time.current,
              status: 'transferred',
              updated_at: Time.current,
              sec_status: 'Completed',
              sec_reference_number: sec_ref_number,
          })
          puts "********* request updated successfully *********"
        rescue StandardError => e
          puts "Error: #{e.message}"
        end
      end

      # contract_ids.each do |contract_id|
      #   puts "********* whose turn: #{contract_id} *********"
      #   begin
      #     request = request_repository.find_by!(
      #       {
      #         contract_id: contract_id,
      #         request_type: 'move_in',
      #         request_number: 'ZA5SX2XYGA4D'
      #       }
      #     )
      #     pp request

      #     request_repository.update!(request._id, {
      #         status: 'canceled',
      #         updated_at: Time.current,
      #         sec_status: 'Cancelled',
      #         # sec_reference_number: '2010573227',
      #     })
      #     puts "********* request updated successfully *********"
      #   rescue StandardError => e
      #     puts "Error: #{e.message}"
      #   end
      # end
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