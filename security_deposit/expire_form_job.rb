namespace :custom_tasks do
  desc "ES_4819_expire_form_job"
  task ES_4819_expire_form_job: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)

    done_cases = []   

    contract_ids = [
      'efe93ff5-72ea-41f5-a5f3-e42e3b21b1f0',
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
      
      
    end
    
    puts "[MIMO] Task completed successfully"
    puts "Done cases: #{done_cases}"
  end
end