namespace :custom_tasks do
  desc "ES_5989_create_security_deposit_form"
  task ES_5989_create_security_deposit_form: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)
    contract_service = App::Services::ContractService.new(EFrame::Iam.system_context)

    contract_ids = [
      "d39f5fcb-9e6d-4277-948a-8bea334d26db",
    ]
    
    contract_ids.each do |contract_id|
      puts "\n[MIMO] Processing contract ID: #{contract_id}"

      contract_data = contract_service.expose_contract_data(contract_id)&.deep_symbolize_keys

      puts "[MIMO] Contract data: "
      pp contract_data

      puts "[MIMO] Creating form..."
      contract_data = contract_data&.deep_symbolize_keys
      pp contract_data

      result = unit_security_form_service.on_contract_info_exposed(contract_id, contract_data)
      puts "[MIMO] Result: #{result}"

      puts "Conditions to pass:"
      previous_form = repository.find_by({ contract_id: contract_data[:previous_version_contract_id] })
      pp previous_form

      if previous_form
        puts "Previous form found for contract ID: #{contract_id}"
      else
        puts "Previous form not found for contract ID: #{contract_id}"
      end

      auto_renewal = contract_data[:contract_number] == previous_form&.contract_number
      puts "Auto renewal: #{auto_renewal}"
      form = repository.find_by({ contract_id: contract_id })
      puts "Form: #{form}"

      skip_process = !auto_renewal || (auto_renewal && form.nil?)
      puts "Skip process: #{skip_process}"

      if skip_process
        form_params = previous_form.to_h.except(:id, :contract_id, :party_response_matched).merge(
            is_archived_form: true,
            contract_id: contract_id,
            previous_form_id: previous_form&.id&.to_s,
            mo_editable: false
        )
        
        applicable_statuses = %W[waiting_parties waiting_lessor waiting_tenant]
        # Reset MI/MO clone form status to avoid party submit form
        form_params[:mi_status] = nil if applicable_statuses.include?(previous_form&.mi_status)
        form_params[:mo_status] = nil if applicable_statuses.include?(previous_form&.mo_status)

        pp form_params

        puts "Form created: "
        pp repository.create(form_params)
      end
    end
  end
end