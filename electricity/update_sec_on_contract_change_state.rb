contract_ids = [
  "78d7e964-c51d-41a8-bc53-95ce59baf00a",
]

contract_ids.each do |contract_id|
  contract = Domain::Contract::Model::Contract.find(contract_id)

  response = ::Domain::Contract::Jobs::Sec::HandleContractStateChangedJob.perform_now(
        contract_id: contract.id,
        contract_state: contract.state
  )

  puts "response: #{response}"
end

# when above job is called, if the MI request is having EJAR status as 'to_be_transferred' and contract is active only then MI is called otherwise not
# If the MI is already approved and there's no MI processed yet then update the status of MI request back to to_be_transferred and call the job again.
# Sometimes, SEC returns response 'MO not possible on this date' when the MI request is transferred and MO if approved but the contract is still active.

# MO request can only be created and processed when contract is having live MI request

# When meter is linked to another archived contract then you need to cancel that request to MI with the contract you want.

# When contract is archived then MI request needs to be cancelled. For this, execute this script.
