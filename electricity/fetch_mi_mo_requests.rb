namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_6222_print_sec_mi_mo: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      contract_ids = [
        "04aa89b8-f768-43bf-bb7b-65bff7bd6eeb"
      ].uniq

      contract_ids.each do |contract_id|
        mi_requests = request_repository.index(
          filters: {
            contract_id: contract_id,
            request_type: 'move_out'
          },
          page: 1,
          items_per_page: 10,
          sort: { created_at: -1 }
        )

        pp mi_requests
      end
    end
  end
end