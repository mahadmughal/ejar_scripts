namespace :custom_tasks do
  desc "ES_1111_debug_script"
  task ES_1111_debug_script: :environment do
    contract_service = App::Services::ContractService.new(EFrame::Iam.system_context)
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)

    new_contract_id = "7c19041d-1caf-475d-ac50-a80e62afd87c"
    old_contract_id = "08763843-5954-4c96-a0a6-4c1d57e60a6c"

    params = contract_service.expose_contract_data(new_contract_id, old_contract_id)

    origin_form = repository.find_by({ contract_id: params[:old_contract_id] })

    puts "\n\n************* Origin Form ***********"
    pp origin_form

    form_params = origin_form.to_h.except(
          :id, :contract_id, :party_response_matched, :is_archived_form
        ).merge(
          App::Services::UnitSecurityFormBuilder.new(params).new_parties
        ).merge(
          reference_form_id: origin_form.id,
          contract_id: new_contract_id
        )

    puts "\n\n************* Form Params ***********"
    pp form_params
  end
end