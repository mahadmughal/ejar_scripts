namespace :custom_tasks do
  desc "ES_5882_contract_state_not_updated"
  task ES_5882_contract_state_not_updated: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)

    forms = repository.scoped(:read)
          .select(:contract_id)
          .where(
            contract_state: ['registered', 'active'],
            mo_status: ['expired', 'done'],
            mo_lessor_status: ['expired', 'done'],
            mo_tenant_status: ['expired', 'done']
          )
          .exclude(security_deposit_invoice_number: nil)

    puts "total records with contract_state not updated: #{forms.count}"
    pp forms.map { |form| form }
  end
end