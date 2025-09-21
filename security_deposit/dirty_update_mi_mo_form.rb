namespace :custom_tasks do
  desc "ES_6170_update_mi_mo_forms"
  task ES_6170_update_mi_mo_forms: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)

    done_cases = [] 

    contract_ids = [
      "6c1d9a5c-dda7-4b78-8069-9cfd08626fed",
    ]

    contract_ids.each do |contract_id|
      puts "\n[MIMO] Processing contract ID: #{contract_id}"
      
      # Find the form for this contract
      form = repository.find_by({ contract_id: contract_id })
      contract_number = form&.contract_number
      
      if form.nil?
        puts "[MIMO] No form found for contract number: #{contract_number}"
        next
      end
      
      # if form.mo_lessor_submitted_at.present?

        attributes = {
          # mo_created_date: Date.current.strftime('%F'),
          # mo_activated_date: Date.current.strftime('%F'),
          # mo_status: 'waiting_parties',
          # mo_form_number: "Move-Out-10798360455",
          # mo_tenant_status: 'expired',
          # mo_lessor_status: 'expired',
          # security_deposit_invoice_number: '2506049804205'
          # mi_created_date: (Date.current - 10.days).strftime('%F'),
          mi_activated_date: Date.current.strftime('%F'),
          mi_status: 'waiting_parties',
          # mi_form_number: "Move-In-10466546392",
          # mo_tenant_status: 'expired',
          # mo_tenant_answer: form.mo_lessor_answer,
          # mo_tenant_reason: form.mo_lessor_reason,
          # mo_damage_amount_by_tenant: form.mo_damage_amount_by_lessor,
          # mi_lessor_status: 'expired',
          # mo_editable: true,
          # contract_number: '10506687099',
          # contract_start_date: '2025-01-04',
          # contract_end_date: '2025-07-23'
          # contract_state: 'terminated'
        }

        # system_response = {
        #     response_at: Date.current,
        #     response_reason: App::Model::UnitSecurityForm::SYSTEM_RESPONSE_REASON[:one_party],
        #     no_response_party_name: form.tenant_name,
        #     no_response_by_parties: false
        # }

        # attributes.merge!(system_response: system_response.to_json)

        # following attributes are for MO form creation
        # attributes = {
        #   form_type: "move_in",
        #   mo_created_date: Date.current.strftime('%F'),
        #   mo_activated_date: Date.current.strftime('%F'),
        #   mo_status: 'waiting_parties',
        #   mo_form_number: "Move-Out-#{contract_number}",
        #   mo_tenant_status: 'waiting_parties',
        #   mo_lessor_status: 'waiting_parties',
          # mo_lessor_answer: 'yes',
          # mo_tenant_answer: 'yes',
          # mo_editable: true
        # }

        repository.update!(form.id, attributes)
        done_cases.push(contract_id)
    end
    
    puts "[MIMO] Task completed successfully"
    puts "Done cases: #{done_cases}"
  end
end