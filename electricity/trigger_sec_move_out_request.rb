contract_numbers = [
  '20837580127',
]

contract_numbers.each do |contract_number|
  puts "************ whose turn: #{contract_number} ************"

  contract = Domain::Contract::Model::Contract.where(contract_number: contract_number, state: ['terminated', 'expired', 'active', 'archived', 'rejected']).order(created_at: :desc).first

  if contract.present?
    puts "*********** start processing move_out **********"
    Ejar3::SecApi.sec_request.bulk_sync_and_do_move_out([contract.id])
    puts "*********** move_out processed successfully **********"
  else
    puts "*********** contract is neither terminated nor expired **********"
  end
end

# NOTES:

# when move_in is in pending state and try to execute above script then system does not move in.
# tenant cannot move_in and move_out on same day.
