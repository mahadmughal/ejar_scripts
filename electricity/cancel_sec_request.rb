#SEC
namespace :custom_tasks do
  desc "Execute my custom script"
  task ES_8471_cancel_sec_mi_mo: :environment do
    EFrame.db_adapter.with_client do
      contract_repository = App::Model::ContractRepository.new(EFrame::Iam.system_context)
      request_repository = App::Model::SecRequestRepository.new(EFrame::Iam.system_context)
      external_call_repository = App::Model::ExternalCallRepository.new(EFrame::Iam.system_context)

      request_numbers = [
        "WW27NGDGHZSS",
      ]

      request_numbers.each do |request_number|
        puts "********* whose turn: #{request_number} *********"
        
        request = request_repository.find_by(
          { request_number: request_number }
        )
        if request.present?
          request_repository.update!(
            request.id,
            { status: 'canceled', updated_at: Time.current}
          )
          puts "Canceled request: #{request_number}"
        end
      end

      # puts "********* SIDEKIQ_USERNAME: #{ENV['SIDEKIQ_USERNAME']} *********"
      # puts "********* SIDEKIQ_PASSWORD: #{ENV['SIDEKIQ_PASSWORD']} *********"
    end; 0
  end
end; 0

# end move in & move out
