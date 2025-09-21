namespace :custom_tasks do
  desc "ES_4622_update_mi_mo_forms"
  task ES_4622_update_mi_mo_forms: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)

    contract_ids_with_mo_expired = []
    already_expired_contracts = []
    
    contract_ids = [
        "70469650-03b0-4314-a8e1-296f70553c4c",
        "d489d349-5ec1-4df2-8b41-db5dcda0f604",
        "13409074-cde4-49f2-aa88-c1f0932fb496",
        "ada1fd17-8b64-4320-8bff-bcec168f4e1f",
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
      
      puts "[MIMO] Found form with ID: #{form.id}"
      puts "[MIMO] Current MI status: #{form.mi_status || 'nil'}, MO status: #{form.mo_status || 'nil'}"
      
      # Track if we made any updates
      updated = false
      
      # Check if move-in form should be expired
      mi_should_expire = false
      if %w[waiting_parties waiting_lessor waiting_tenant].include?(form.mi_status) && form.mi_activated_date.present?
        begin
          threshold_date = App::Model::UnitSecurityForm::NO_OF_DAYS_TO_EXPIRE.days.ago
          mi_should_expire = form.mi_activated_date < threshold_date
        rescue => e
          puts "[MIMO] Error parsing MI date: #{e.message}"
        end
      end
      
      puts "[MIMO] Move-in form should expire: #{mi_should_expire}, MI activation date: #{form.mi_activated_date}"
      if mi_should_expire
        puts "[MIMO] MI activation date: #{form.mi_activated_date}, Expiration threshold: #{App::Model::UnitSecurityForm::NO_OF_DAYS_TO_EXPIRE.days.ago.to_date}"
      end

      # Check if both forms are already expired or done
      if ['expired', 'done'].include?(form.mi_status) && ['expired', 'done'].include?(form.mo_status)
        puts "[MIMO] Both MI and MO forms are already expired or done for contract #{contract_number}"
        already_expired_contracts.push(contract_id)
        next
      end

      # Process move-in form expiration if needed
      if mi_should_expire
        puts "[MIMO] Processing move-in form expiration..."
        mi_attributes = { mi_status: 'expired' }
        
        case form.mi_status
        when 'waiting_tenant'
          mi_attributes.merge!(
            mi_tenant_status: 'expired',
            mi_tenant_answer: 'no_response'
          )
          puts "[MIMO] Setting tenant status to expired and answer to no_response"
        when 'waiting_lessor'
          mi_attributes.merge!(
            mi_lessor_status: 'expired',
            mi_lessor_answer: 'no_response'
          )
          puts "[MIMO] Setting lessor status to expired and answer to no_response"
        when 'waiting_parties'
          mi_attributes.merge!(
            mi_lessor_answer: 'no_response',
            mi_lessor_status: 'expired',
            mi_tenant_answer: 'no_response',
            mi_tenant_status: 'expired'
          )
          puts "[MIMO] Setting both parties statuses to expired and answers to no_response"
        end
        
        puts "[MIMO] Updating MI form with attributes: #{mi_attributes.inspect}"
        repository.update!(form.id, mi_attributes) unless mi_attributes.blank?
        updated = true
      end
      
      # Check if move-out form should be expired
      mo_should_expire = %w[nil waiting_parties waiting_lessor waiting_tenant].include?(form.mo_status) &&
                         form.mo_activated_date.present? &&
                         form.mo_activated_date < App::Model::UnitSecurityForm::NO_OF_DAYS_TO_EXPIRE.days.ago
      
      puts "[MIMO] Move-out form should expire: #{mo_should_expire}, MO activation date: #{form.mo_activated_date}"
      if mo_should_expire
        puts "[MIMO] MO activation date: #{form.mo_activated_date}, Expiration threshold: #{App::Model::UnitSecurityForm::NO_OF_DAYS_TO_EXPIRE.days.ago.to_date}"
      end
      
      # Process move-out form expiration if needed
      if mo_should_expire
        puts "[MIMO] Processing move-out form expiration..."
        mo_attributes = { mo_status: 'expired' }
        
        case form.mo_status
        when 'waiting_tenant'
          system_response = {
            response_at: Date.current,
            response_reason: App::Model::UnitSecurityForm::SYSTEM_RESPONSE_REASON[:one_party],
            no_response_party_name: form.tenant_name,
            no_response_by_parties: false
          }
          
          mo_attributes.merge!(
            mo_tenant_status: 'expired',
            system_response: system_response.to_json,
            mo_tenant_answer: form.mo_lessor_answer,
            mo_tenant_reason: form.mo_lessor_reason,
            mo_damage_amount_by_tenant: form.mo_damage_amount_by_lessor,
            mo_editable: false
          )
          puts "[MIMO] Setting tenant status to expired and copying lessor's answers"
          puts "[MIMO] System response: #{system_response.inspect}"
        when 'waiting_lessor'
          system_response = {
            response_at: Date.current,
            response_reason: App::Model::UnitSecurityForm::SYSTEM_RESPONSE_REASON[:one_party],
            no_response_party_name: form.lessor_name,
            no_response_by_parties: false
          }
          
          mo_attributes.merge!(
            mo_lessor_status: 'expired',
            system_response: system_response.to_json,
            mo_lessor_answer: form.mo_tenant_answer,
            mo_lessor_reason: form.mo_tenant_reason,
            mo_damage_amount_by_lessor: form.mo_damage_amount_by_tenant,
            mo_editable: false
          )
          puts "[MIMO] Setting lessor status to expired and copying tenant's answers"
          puts "[MIMO] System response: #{system_response.inspect}"
        when 'waiting_parties'
          system_response = {
            response_at: Date.current,
            response_reason: App::Model::UnitSecurityForm::SYSTEM_RESPONSE_REASON[:both_parties],
            no_response_party_name: nil,
            no_response_by_parties: true
          }
          
          mo_attributes.merge!(
            mo_lessor_answer: 'yes',
            mo_lessor_status: 'expired',
            mo_tenant_answer: 'yes',
            mo_tenant_status: 'expired',
            system_response: system_response.to_json,
            mo_editable: false
          )
          puts "[MIMO] Setting both parties statuses to expired and answers to 'yes'"
          puts "[MIMO] System response: #{system_response.inspect}"
        end
        
        puts "[MIMO] Updating MO form with attributes: #{mo_attributes.inspect}"
        repository.update!(form.id, mo_attributes) unless mo_attributes.blank?
        updated = true
        contract_ids_with_mo_expired.push(contract_id)
      end
      
      # Reload the form to get the updated statuses
      form = repository.find_by!({ id: form.id }) if updated
      
      # Update statistics if updates were made
      if updated
        # Increment statistics
        if form.mi_status == 'expired'
          puts "[MIMO] Updating MI statistics for expired forms"
          unit_security_form_service.update_unit_security_form_statistic('total_unit_move_in_form_expired', nil, 1)
        end
        
        if form.mo_status == 'expired'
          puts "[MIMO] Updating MO statistics for expired forms"
          unit_security_form_service.update_unit_security_form_statistic('total_unit_move_out_form_expired', nil, 1)
        end
        
        # Log the final update
        puts "[MIMO] Final form status - MI: #{form.mi_status || 'nil'}, MO: #{form.mo_status || 'nil'}"
      else
        puts "[MIMO] No updates needed for contract #{contract_number}"
      end
      
      puts "[MIMO] Completed processing for contract #{contract_number}"
      puts "=" * 80
    end
    
    puts "[MIMO] Task completed successfully"

    puts "[MIMO] Contract IDs with MO expired: #{contract_ids_with_mo_expired}"
    puts "[MIMO] Contract IDs with already expired/done: #{already_expired_contracts}"
  end
end
