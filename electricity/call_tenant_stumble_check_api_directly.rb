require 'net/http'
require 'uri'
require 'json'

# API endpoint details
url = 'https://integration-gw.nhc.sa/nhc/prod/v1/sec/tenantStumbleCheck'
client_id = 'dac65968af42d405e7f6b0bdb2ba7b54'
client_secret = '32a118e4d2a822fb4f7876d4314a8a4d'

# Generate current timestamp
current_time = Time.now.to_i

# Prepare request payload
payload = {
  "Header" => {
    "CallerReqTime" => current_time.to_s,
    "RefId" => "1"
  },
  "Body" => {
    "idType" => "ZOCRN",
    "idNumber" => "7005483842"
  }
}

pp payload

# Convert payload to JSON
json_payload = payload.to_json

# Create URI object
uri = URI.parse(url)

# Create HTTP object
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

# Create request
request = Net::HTTP::Post.new(uri.path)

# Set headers
request['Content-Type'] = 'application/json'
request['RefId'] = 1
request['X-IBM-Client-Id'] = client_id
request['X-IBM-Client-Secret'] = client_secret
request['CallerReqTime'] = current_time
request.body = json_payload

puts "\nRequest Params:"
puts "  URL: #{url}"
puts "  Method: #{request.method}"
puts "  Headers:"
request.each_header do |key, value|
  puts "    #{key}: #{value}"
end
puts "  Body: #{request.body}"

# Send request and get response
begin
  response = http.request(request)
  puts "Response Status: #{response.code}"
  puts "Response Body: #{response.body}"
  
  # Parse and display JSON response
  if response.code == '200'
    response_data = JSON.parse(response.body)
    puts "\nParsed Response:"
    puts JSON.pretty_generate(response_data)
  end
rescue => e
  puts "Error: #{e.message}"
end