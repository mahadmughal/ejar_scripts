namespace :custom_tasks do
  desc "ES_6777_refund_security_deposit"
  task ES_6777_refund_security_deposit: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)

    contract_ids = [
      ["926cdca1-7274-4711-b1ad-b20c251725b2", "10690641116", "terminated"],
      ["130a0ff3-f393-4da3-b480-e17e9dbfdc4b", "10503849981", "terminated"],
      ["f6e7d786-35fc-4f76-98b5-02531affeed8", "10027250977", "expired"]
    ]

    contract_ids.each do |contract_id|
      puts "\n[MIMO] Processing contract ID: #{contract_id}"
      
      # Find the form for this contract
      form = repository.find_by({ contract_id: contract_id })
      # form = repository.find_by({ contract_number: contract_id })
      contract_id = form&.contract_id
      contract_number = form&.contract_number

      if form.nil?
        puts "[MIMO] No form found for contract ID: #{contract_id}"
        next
      end

      puts "Form:"
      pp form

      puts "[MIMO] Found form with ID: #{form.id}"
      puts "[MIMO] Current MI status: #{form.mi_status || 'nil'}, MO status: #{form.mo_status || 'nil'}"

      if form.mo_damage_amount_by_lessor.present? || form.mo_damage_amount_by_tenant.present?
        puts "******** Involved damage evaluation *********"
        next
      end

      auto_renewal = false
      # skip if form is manual contract cloned form
      if form.previous_form_id
        auto_renewal = repository.find_by({
          id: form.previous_form_id,
          contract_number: form.contract_number
        }).present?

        return unless auto_renewal
      end

      if form.mo_status == 'expired' || form.mo_status == 'done'
        unless form.security_deposit_invoice_number
          puts "[MIMO] No security deposit invoice number found for contract number: #{contract_number}"
          next
        end

        if form.is_archived_form
          puts "[MIMO] Skipping refund for archived form"
          next
        end

        if %w(registered active).include?(form&.contract_state)
          puts "[MIMO] Contract state is registered or active so not refund"
          next
        end

        refund_handler = App::Services::RefundService.new(form: form)
        puts "[MIMO] Expert damage evaluation: #{refund_handler.expert_damage_evaluation}"
        refund_handler.expert_damage_evaluation
        puts "[MIMO] Refund amount: #{refund_handler.refund_amount}"
        refund_handler.refund_amount

        refund_call = refund_handler.call

        # if refund_call
        #   App::Services::SmsService.new(form: form).call
        #   puts "[MIMO] Refund SMS sent for contract number: #{contract_number}"
        # end
      end

      Workers::UnitSecurityForms::UpdateCoreContract.perform_in(0.seconds, form.id)

      if !auto_renewal
        Workers::UnitSecurityForms::UpdateCloneForm.perform_in(0.seconds, form.id)
      end
    end
  end
end