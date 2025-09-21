#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_627_cancel_sec_mi_mo_using_contract_number: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      contract_numbers = [
        '10816924964',
        '10700432895',
        '10976104619',
        '10747015009',
        '10167393124',
        '20690986698',
        '10541717429',
        '10327453417',
        '20755739454',
        '10441876378',
        '10574835085',
        '10444412831',
        '10097613582',
        '10441876378',
        '10813041221',
      ]

      requests = request_repository.index(
        filters: {
          contract_number: contract_numbers
        },
        page: 1,
        items_per_page: 10,
        sort: { created_at: -1 }
      )

      requests.each do |request|
        request_repository.update!(
          request.id,
          { status: 'canceled', updated_at: Time.current}
        )
        puts "request canceled with contract number: #{request.contract_number}"
      end
    end; 0
  end
end; 0

# end move in & move out
