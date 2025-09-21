contract_numbers = [
  '10831817790',
]

result = []

contract_numbers.each do |contract_number|
  puts "********* whose turn: #{contract_number} *********"

  contract = Domain::Contract::Model::Contract.where(contract_number: contract_number).order(created_at: :desc).first

  contract_portfolio_units = contract.contract_property.units

  contract_portfolio_units.each do |contract_portfolio_unit|
    unit_services = contract_portfolio_unit.contract_unit&.contract_unit_services
    electricity_unit_service = unit_services&.find_by(utility_service_type: 'electricity')

    result << {
      contract_number: contract_number,
      unit_number: contract_portfolio_unit.unit_number,
      premise_id: electricity_unit_service&.electricity_premise_id,
      electricity_meter: contract_portfolio_unit.utilities['electricity_meter'],
      account_no: electricity_unit_service&.account_no
    }
  end
end

puts "************* Result ************"
pp result
