require 'net/http'
require 'uri'
require 'json'
require 'time'

# API endpoint and credentials
base_url = "https://integration-gw.nhc.sa/nhc/prod/v1/sec/premiseCheck"
client_id = "dac65968af42d405e7f6b0bdb2ba7b54" 
client_secret = "32a118e4d2a822fb4f7876d4314a8a4d"
premise_id = "4004111502"  # The premise ID to check

# Build the URL with query parameters
uri = URI(base_url)
params = { premiseID: premise_id }
uri.query = URI.encode_www_form(params)

puts "Full URL with parameters: #{uri.to_s}"

# Set up HTTP connection
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

# Create timestamp for the request
caller_req_time = Time.now.to_i

# Create and configure the request
request = Net::HTTP::Get.new(uri.request_uri)  # This includes the query parameters
request['RefId'] = 1
request['X-IBM-Client-Id'] = client_id
request['X-IBM-Client-Secret'] = client_secret
request['CallerReqTime'] = caller_req_time

begin
  puts "----------------Checking Premise #{premise_id}---------------------"
  puts "Sending request to: #{uri.to_s}"
  puts "With headers: RefId=1, X-IBM-Client-Id=#{client_id}, CallerReqTime=#{caller_req_time}"
  
  # Send the request
  response = http.request(request)
  
  # Parse the response
  if response.body && !response.body.empty?
    response_body = JSON.parse(response.body)
    
    # Display the response
    puts "\nResponse status: #{response.code}"
    
    if response.code.to_i == 200
      message_code = response_body.dig("EJARPremiseCheckResponse", "Result", "MessageCode")
      message_text = response_body.dig("EJARPremiseCheckResponse", "Result", "MessageText")
      
      puts "Message: #{message_code} - #{message_text}"
      
      # Create the result structure matching the expected format
      result = {
        _id: "BSON::ObjectId('#{Time.now.to_i.to_s(16)}0000000000')",
        parameters: { "premiseID" => premise_id },  # What was sent as query params
        payload: response_body,  # The API response data
        request: {
          method: "get",
          url: base_url,
          headers: {
            "RefId" => 1,
            "X-IBM-Client-Id" => client_id,
            "X-IBM-Client-Secret" => client_secret,
            "CallerReqTime" => caller_req_time
          },
          params: { "premiseID" => premise_id }  # Explicitly showing params separately
        },
        response: response,
        status: :success,
        error_type: nil,
        error_message: nil,
        created_at: Time.now.utc
      }
      
      # Pretty print the result (in a format similar to your example)
      puts "\nAPI Result Object:"
      puts "{:_id=>BSON::ObjectId('#{Time.now.to_i.to_s(16)}0000000000'),"
      puts " :parameters=>{\"premiseID\"=>\"#{premise_id}\"},"
      puts " :payload=>"
      puts "   #{JSON.pretty_generate(response_body).gsub(/^/, '   ')},"
      puts " :request=>"
      puts "   {\"method\"=>\"get\","
      puts "    \"url\"=>\"#{base_url}\","
      puts "    \"headers\"=>"
      puts "     {\"RefId\"=>1,"
      puts "      \"X-IBM-Client-Id\"=>\"#{client_id}\","
      puts "      \"X-IBM-Client-Secret\"=>\"#{client_secret}\","
      puts "      \"CallerReqTime\"=>#{caller_req_time}},"
      puts "    \"params\"=>{\"premiseID\"=>\"#{premise_id}\"}},"
      puts " :response=>\"#<Net::HTTPOK #{response.code} #{response.message} readbody=true>\","
      puts " :status=>:success,"
      puts " :error_type=>nil,"
      puts " :error_message=>nil,"
      puts " :created_at=>#{Time.now.utc}}"

      puts "\nAPI Response Object: #{response_body}"
      
      # Extract and show some key details from the response
      if premise_details = response_body.dig("EJARPremiseCheckResponse", "EJARPremiseCheck")
        puts "\nPremise Details:"
        puts "  Premise ID: #{premise_details["PremiseID"]}"
        puts "  Outstanding Balance: #{premise_details["OutstandingBalanceofPremise"]}"
        puts "  Next Schedule Invoice Date: #{premise_details["NextScheduleInvoiceDate"]}"
        puts "  Site Scenario: #{premise_details["SiteScenario"]}"
        
        if meter_details = premise_details["MeterDetails"]
          puts "  Meter Details:"
          puts "    Meter Number: #{meter_details["MeterNumber"]}"
          puts "    Equipment Number: #{meter_details["EquipmentNumber"]}"
        end
      end
    else
      puts "Error: Non-200 response code received: #{response.code}"
      puts "Response body: #{response.body}"
    end
  else
    puts "Error: Empty response body"
  end
  
rescue => e
  puts "Exception occurred: #{e.message}"
  puts e.backtrace
end

puts "----------------End Premise Check for #{premise_id}---------------------"