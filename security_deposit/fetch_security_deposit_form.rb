namespace :custom_tasks do
  desc "ES_5989_fetch_security_deposit_form"
  task ES_5989_fetch_security_deposit_form: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    contract_ids = [
      "10246488839",
    ]

    result = []

    expired_cases = []                                         

    contract_ids.each do |contract_id|
      puts "Contract number: #{contract_id}"

      # puts "Form type: move_in"
      # form = repository.find_by({ contract_number: contract_id})
      # form = repository.find_by({ contract_id: contract_id})
      form = repository.index(filters: { contract_number: contract_id})

      pp form
      # contract_id = form&.contract_id
      contract_number = form&.contract_number

      unless form
        pp "======= Contract: #{contract_number} - NO MOVE IN FORM ======="
        next
      end

      # puts "Form status: #{form.mi_status}"
      pp form

      # if form.mo_status == "expired" || form.mo_status == "done"
      #   expired_cases.push(contract_id)
      # end

      # if form&.previous_form_id
      #   pp "======= Contract: #{contract_number} - Cloned form ======="
      # end

      # puts "======= Found form ======="
      # if form.refund_details.present?
      #   result.push(
      #     "contract_id: #{contract_id}", 
      #     "contract_number: #{contract_number}", 
      #     "tenant_id_number: #{form.tenant_id_number}", 
      #     "lessor_id_number: #{form.lessor_id_number}", 
      #     "refund_details: #{form.refund_details}",
      #     "invoice_number: #{form.security_deposit_invoice_number}"
      #   )
      # end

      # puts "expired cases: #{expired_cases}"
    end
    
    puts "************** Result **************"
    pp result
  end
end