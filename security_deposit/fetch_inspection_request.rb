namespace :custom_tasks do
  desc "ES_4302_fetch_inspection_request"
  task ES_4302_fetch_inspection_request: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)
    inspection_request_repo = App::Model::InspectionRequestRepository.new(EFrame::Iam.system_context)

    contract_ids = [
      "f8d376a1-4f81-4170-911a-62f1c674fa21"
    ]

    contract_ids.each do |contract_id|
      puts "\n[MIMO] Processing contract ID: #{contract_id}"
      
      # Find the form for this contract
      form = repository.find_by({ contract_id: contract_id })
      contract_number = form&.contract_number

      if form.nil?
        puts "[MIMO] No form found for contract ID: #{contract_id}"
        next
      end

      inspection_request = inspection_request_repo.find_by({
        contract_id: contract_id, 
        unit_security_form_id: form.id
      })

      puts "*********** inspection_request ***********"
      pp inspection_request

      if inspection_request
        puts "[MIMO] Inspection request found for contract ID: #{contract_id}"
      else
        puts "[MIMO] No inspection request found for contract ID: #{contract_id}"
      end
    end
  end
end