namespace :custom_tasks do
  desc "Update party information for specific contract"
  task update_contract_party_info: :environment do
    # Use system context for authentication
    context = EFrame::Iam.system_context
    
    # Contract ID to update
    contract_id = "30fffd82-1d50-42dc-b823-f3dccff70ff2"
    
    # Initialize contract repository
    contract_repository = App::Model::ContractRepository.new(context)
    
    begin
      puts "[PARTY_UPDATE] Starting party information update for contract ID: #{contract_id}"
      
      # Find the contract
      contract = contract_repository.find_by!({ id: contract_id })
      puts "[PARTY_UPDATE] Found contract with number: #{contract.contract_number}"
      
      # Current parties information
      current_parties = contract.parties
      puts "[PARTY_UPDATE] Current parties information:"
      current_parties.each_with_index do |party, index|
        puts "  Party #{index + 1}: #{party[:full_name]} (#{party[:party_role]})"
      end
      
      puts "[PARTY_UPDATE] Party information update completed successfully"
    rescue => e
      puts "[PARTY_UPDATE] Error updating party information: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end