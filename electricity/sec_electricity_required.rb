contract_ids = [
  'f41354a8-e314-4200-953f-6f2c398dd33f'
]

contract_ids.each do |contract_id|
  puts "********* whose turn: #{contract_id} *********"

  contract = Domain::Contract::Model::Contract.find(contract_id)

  puts "********* SEC electricity service required ? *********"

  exists = contract.contract_unit_services
      .where(utility_service_type: 'electricity')
      .where(to_be_paid_by: [nil, Domain::Contract::Model::ContractUnitService.to_be_paid_bies[:metered_fee]])
      .exists?

  pp exists
end
