#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_369_reflect_meter_info_in_core: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)

      contract_ids = [
        'bb1bd9d7-6ffa-4ef8-93e6-01e92ad6d0cb'
      ]

      request_numbers = [
        'T5ZXYHYQEXWZ'
      ]

      request_numbers.each do |request_number|
        sec_request = request_repository.find_by!({
          request_number: request_number,
          request_type: 'move_in'
        })

        App::Services::Validation::MoveInValidation.validate(
            request_number: request_number
          )

        result = sec_service.reflect_meter_number_to_core(
          sec_request: sec_request,
          target: 'contract'
        )

        puts "*********** result ***********"
        pp result
      end
    end; 0
  end
end; 0