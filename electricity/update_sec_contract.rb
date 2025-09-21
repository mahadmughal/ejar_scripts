#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_1678_update_sec_contract_info: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)
      sec_service = App::Services::SecRequestService.new(EFrame::Iam.system_context)
      sec_notify_service = App::Services::SecNotifyingService.new(EFrame::Iam.system_context)

      contract_details = [
        {old_contract_id: '4430065a-5a8f-478e-84f3-f2d45b7767a9', new_contract_id: 'b1ac0c93-b908-4ab5-982d-d226ac60b9f4', notify_type: 'auto_renew'}, 
      ]

      contract_details.each do |contract_detail|
        old_contract_id = contract_detail[:old_contract_id]
        new_contract_id = contract_detail[:new_contract_id]
        notify_type = contract_detail[:notify_type]
        
        sec_notify_service.call(old_contract_id: old_contract_id, new_contract_id: new_contract_id, notify_type: notify_type)
      end
    end; 0
  end
end; 0
