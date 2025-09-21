require 'net/http'
require 'uri'
require 'json'
require 'time'

class EjarMoveOutClient
  attr_reader :base_url, :client_id, :client_secret
  
  def initialize(
    base_url: 'https://integration-gw.nhc.sa/nhc/prod/v1/sec/moveOut',
    client_id: 'dac65968af42d405e7f6b0bdb2ba7b54',
    client_secret: '32a118e4d2a822fb4f7876d4314a8a4d'
  )
    @base_url = base_url
    @client_id = client_id
    @client_secret = client_secret
  end
  
  def move_out(contract_number:, move_out_date:, premise_id:, equipment_number:, tenant_id_number:, meter_reading_date:, tenant_id_type:)
    # Create request payload
    payload = {
      EJARMoveOutRequest: {
        eJARContractNumber: contract_number,
        moveOutDate: move_out_date,
        autoMOFlag: "X",
        TenantDetails: {
          tenantIDType: tenant_id_type, 
          tenantIDNumber: tenant_id_number
        },
        PremiseDetails: {
          premiseID: premise_id,
          siteScenario: "SN",
          MeterDetails: {
            equipmentNumber: equipment_number,
            meterReading: "",
            meterReadingDate: meter_reading_date
          }
        }
      }
    }
    
    # Make the API call
    response = send_request(payload)
    
    # Log the request details
    log_request_details(contract_number, response)
    
    return response
  end
  
  private
  
  def send_request(payload)
    url = URI.parse(@base_url)
    
    # Set up the HTTP connection
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    
    # Create the request
    request = Net::HTTP::Post.new(url.path)
    
    # Set the headers
    request['RefId'] = 1
    request['X-IBM-Client-Id'] = @client_id
    request['X-IBM-Client-Secret'] = @client_secret
    request['CallerReqTime'] = Time.now.to_i
    request['Content-Type'] = 'application/json'
    
    # Set the request body
    request.body = payload.to_json
    
    begin
      # Send the request
      response = http.request(request)
      
      # Parse the response
      parsed_response = JSON.parse(response.body)
      
      return {
        status: response.code.to_i == 200 ? :success : :error,
        payload: parsed_response,
        request: {
          method: 'post',
          url: @base_url,
          headers: {
            'RefId' => 1,
            'X-IBM-Client-Id' => @client_id,
            'X-IBM-Client-Secret' => @client_secret,
            'CallerReqTime' => Time.now.to_i
          },
          body: payload.to_json
        },
        response: response,
        error_type: nil,
        error_message: nil,
        created_at: Time.now.utc
      }
    rescue => e
      return {
        status: :error,
        payload: nil,
        request: {
          method: 'post',
          url: @base_url,
          headers: {
            'RefId' => 1,
            'X-IBM-Client-Id' => @client_id,
            'X-IBM-Client-Secret' => @client_secret,
            'CallerReqTime' => Time.now.to_i
          },
          body: payload.to_json
        },
        response: nil,
        error_type: e.class.name,
        error_message: e.message,
        created_at: Time.now.utc
      }
    end
  end
  
  def log_request_details(contract_number, response)
    puts "----------------Check Move out Request for #{contract_number}---------------------"
    puts "API Response Status: #{response[:status]}"
    puts "Response Payload: #{response[:payload]}"
    
    if response[:status] == :success
      message_code = response[:payload].dig('EJARMoveOutResponse', 'Result', 'MessageCode')
      message_text = response[:payload].dig('EJARMoveOutResponse', 'Result', 'MessageText')
      
      puts "Message Code: #{message_code}"
      puts "Message Text: #{message_text}"
    end
    
    puts "----------------End Move out Request for #{contract_number}---------------------"
  end
end

client = EjarMoveOutClient.new

result = client.move_out(
  contract_number: "10745402098",
  move_out_date: '2025-07-13',
  tenant_id_number: '1066620764',
  tenant_id_type: 'ZNID',
  premise_id: "4010854616",
  equipment_number: "34121825",
  meter_reading_date: "2025-07-02"
)

puts "\nFull API Response:"
puts JSON.pretty_generate(result)