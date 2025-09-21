namespace :custom_tasks do
  desc "ES_5879_fetch_bulk_security_deposit_forms"
  task ES_5879_fetch_bulk_security_deposit_forms: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)

    forms = repository.scoped(:read)
          .select(:id, :security_deposit_invoice_number, :contract_id, :contract_number)
          # .where(Sequel.lit("refund_details->>'message' LIKE ?", "%beneficiaries must be related%"))
          .exclude(refund_details: Sequel.pg_jsonb({}))

    puts "total records with refund_details: #{forms.count}"

    forms = forms.where(Sequel.lit("refund_details->>'message' LIKE ?", "%beneficiaries must be related%"))

    puts "total records with refund_details having beneficiaries must be related: #{forms.count}"


    puts "********** forms **********"
    pp forms.first

    security_deposit_invoice_numbers = forms.map { |form| form[:security_deposit_invoice_number] }

    puts "********** security_deposit_invoice_numbers **********"
    pp security_deposit_invoice_numbers

    contract_numbers = forms.map { |form| form[:contract_number] }

    puts "********** contract_numbers **********"
    pp contract_numbers

    # full message: The beneficiaries must be related to the invoice
  end
end