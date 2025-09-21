namespace :custom_tasks do
  desc "ES_5881_invoice_must_be_in_closed_status"
  task ES_5881_invoice_must_be_in_closed_status: :environment do
    repository = App::Model::UnitSecurityFormRepository.new(EFrame::Iam.system_context)

    forms = repository.scoped(:read)
          .select(:id)
          # .where(Sequel.lit("refund_details->>'message' LIKE ?", "%invoice must be in closed status%"))
          .exclude(refund_details: Sequel.pg_jsonb({}))

    puts "total records with refund_details: #{forms.count}"

    forms = forms.where(Sequel.lit("refund_details->>'message' LIKE ?", "%invoice must be in closed status%"))

    puts "total records with refund_details having invoice must be in closed status: #{forms.count}"

    # full message: The invoice must be in closed status
  end
end