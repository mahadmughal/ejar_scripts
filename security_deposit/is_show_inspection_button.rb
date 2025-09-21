namespace :custom_tasks do
  desc "ES_6507_is_show_inspection_button"
  task ES_6507_is_show_inspection_button: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)
    unit_security_form_service = App::Services::UnitSecurityFormService.new(EFrame::Iam.system_context)

    contract_ids = [
      '78bea618-724f-48f5-b287-e814b97136d4',
    ]

    contract_ids.each do |contract_id|
      form = repository.find_by({ contract_id: contract_id })
      contract_number = form&.contract_number

      if form.nil?
        puts "No form found for contract number: #{contract_number}"
        next
      end

      is_move_out_form = form.form_type == 'move_out'
      is_agreed = nil

      if form.mo_lessor_answer == 'yes' && form.mo_tenant_answer == 'yes'
        is_agreed = true
      elsif form.mo_lessor_answer == 'no' && form.mo_tenant_answer == 'no'
        is_agreed = form.mo_damage_amount_by_lessor == form.mo_damage_amount_by_tenant
      else
        is_agreed = false
      end

      is_not_new_status = form.mo_lessor_status != 'new' && form.mo_tenant_status != 'new'

      if ((Date.today - form.mo_activated_date).to_i) > 7
        is_expired = true
      end

      if form.mo_activated_date >= Date.parse('2024-09-05T00:00:00Z')
        is_activated_date_after_2024_09_05 = true
      end

      puts "is_move_out_form: #{is_move_out_form}"
      puts "is_not_agreed: #{!is_agreed}"
      puts "is_not_new_status: #{is_not_new_status}"
      puts "is_mo_expired: #{is_expired}"
      puts "is_activated_date_after_2024_09_05: #{is_activated_date_after_2024_09_05}"

      is_show_inspection_button = is_move_out_form && !is_agreed && is_not_new_status && is_expired && is_activated_date_after_2024_09_05
      puts "Is show inspection button: #{is_show_inspection_button}"
    end
  end
end