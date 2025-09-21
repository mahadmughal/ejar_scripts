namespace :custom_tasks do
  desc "ES_6339_5630_6489_5903_display_security_deposit_forms"
  task ES_6339_5630_6489_5903_display_security_deposit_forms: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)

    contract_ids = [
      "8ff9444e-f5ce-43dd-b0ec-a8e9ae809845",
      "c1f7b67f-cf6b-4f56-b7f2-869aee1b0992",
      "d1c9a38e-5c5e-4049-a46f-2eec55a84589",
      "f37f4418-f10e-4bc5-a883-76807a6875bc",
      "a0f5f135-5ce7-4a9e-b218-88cdd051c84b",
      "62ec7dd6-59f2-4bf7-942f-d34d1f8d663d",
    ]

    result = []

    contract_ids.each do |contract_id|
      puts "\n[MIMO] Processing contract ID: #{contract_id}"
      
      # Find the form for this contract
      form = repository.find_by({ contract_id: contract_id })
      contract_number = form&.contract_number
      
      if form.nil?
        puts "[MIMO] No form found for contract number: #{contract_number}"
        next
      end
      
      result.push([form.contract_number, form.security_deposit_invoice_number])
    end
    
    puts "[MIMO] Task completed successfully"
    puts "[MIMO] Result: "
    pp result
  end
end