#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_6342_print_sec_move_in_using_filters: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      premise_ids = [
        '4011603055'
      ].uniq

      # electricity_meter_numbers = [
      #   'MMF2020800289818'
      # ]

      # premise_ids.each do |premise_id|
      mi_requests = request_repository.index(
        filters: {
          premise_id: premise_ids,
          request_type: 'move_in',
          # status__in: ['waiting_parties', 'pending', 'approved', 'transferred']
          # status__in: ['failed']
        },
        page: 1,
        items_per_page: 1000,
        sort: { created_at: -1 }
      )

      pp "mi_requests.count: #{mi_requests.count}"
      puts "mi_requests: "
      pp mi_requests
      
      result  = []

      mi_requests.each do |mi_request|
        result << [mi_request.move_in_call_id, mi_request.status, mi_request.sec_status, mi_request.sec_reference_number, mi_request.retried_at]
      end


      pp result

      # contract_ids.each do |contract_id|
        # mo_requests = request_repository.index(
        #   filters: {
        #     contract_id: contract_ids,
        #     request_type: 'move_out'
        #   },
        #   page: 1,
        #   items_per_page: 10,
        #   sort: { created_at: -1 }
        # )

        # mo_requests.each do |mo_request|
        #   pp({
        #     contract_number: mo_request.contract_number,
        #     premise_id: mo_request.premise_id,
        #     equipment_number: mo_request.equipment_number,
        #     meter_reading_date: mo_request.meter_reading_date
        #   })
        # end
      # end
      
    end; 0
  end
end; 0

# end move in & move out
