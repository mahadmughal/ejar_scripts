#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'time'

# Configuration
API_ENDPOINT = 'https://integration-gw.nhc.sa/nhc/prod/v1/sec/moveIn'
CLIENT_ID = 'dac65968af42d405e7f6b0bdb2ba7b54'
CLIENT_SECRET = '32a118e4d2a822fb4f7876d4314a8a4d'

# Create the request payload
def create_move_in_payload(contract_number, contract_start_date, contract_end_date, 
                          premise_id, equipment_number, owner_id, tenant_id)
  
  current_date = Time.now.strftime('%Y-%m-%d')
  
  {
    EJARMoveInRequest: {
      eJARContractNumber: contract_number,
      eJARContractStartDate: contract_start_date,
      eJARContractEndDate: contract_end_date,
      PremiseDetails: [
        {
          premiseID: premise_id,
          ownerValidated: true,
          siteScenario: "SN",
          MeterDetails: [
            {
              equipmentNumber: equipment_number,
              meterReadingDate: current_date,
              meterReading: 0.0
            }
          ],
          OwnerDetails: {
            IndividualOwnerDetails: {
              firstNameofOwnerAr: "عبدالمجيد",
              firstNameofOwnerEn: "عبدالمجيد",
              fathersNameofOwnerAr: "محمد",
              fathersNameofOwnerEn: "محمد",
              grandFatherNameofOwnerAr: "عبدالله",
              grandFatherNameofOwnerEn: "عبدالله",
              familyNameofOwnerAr: "الطريقي",
              familyNameofOwnerEn: "الطريقي",
              ownerIDType: "ZNID",
              ownerIDNumber: owner_id,
              dOBofOwner: "1394-07-01",
              mobileNumberofOwner: "0555566576",
              firstNameofPOAAr: "",
              firstNameofPOAEn: "",
              familyNameofPOAAr: "",
              familyNameofPOAEn: "",
              iDTypeofPOA: "",
              iDNumberofPOA: "",
              dOBofPOA: "",
              mobileNumberofPOA: ""
            }
          }
        }
      ],
      TenantDetails: {
        OrganizationTenantDetails: [
          {
            organizationName1Ar: "شركة الرومانسية مساهمة مقفلة",
            organizationName1En: "شركة الرومانسية مساهمة مقفلة",
            organizationName2Ar: "",
            organizationName2En: "",
            organizationIDType: "ZOCRN",
            organizationIDNumber: tenant_id,
            registrationDate: "2005-12-12",
            OrganizationContactPersonDetails: {
              firstNameofContactPersonAr: "احمد",
              firstNameofContactPersonEn: "احمد",
              fatherNameofContactPersonAr: "محمود",
              fatherNameofContactPersonEn: "محمود",
              grandfatherNameofContactPersonAr: "محمد",
              grandfatherNameofContactPersonEn: "محمد",
              familyNameofContactPersonAr: "الأبي",
              familyNameofContactPersonEn: "الأبي",
              contactPersonIDType: "ZNID",
              contactPersonIDNumber: "1010291613",
              emailIDofContactPerson: "aa3rr@hotmail.com",
              contactPersonMobileNumber: "0533613366"
            }
          }
        ]
      }
    }
  }
end

# Make the API request
def send_move_in_request(payload)
  uri = URI.parse(API_ENDPOINT)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  req = Net::HTTP::Post.new(uri.path)
  req["Content-Type"] = "application/json"
  req["X-IBM-Client-Id"] = CLIENT_ID
  req["X-IBM-Client-Secret"] = CLIENT_SECRET
  req["RefId"] = "1"
  caller_req_time = Time.now.to_i.to_s
  req["CallerReqTime"] = caller_req_time
  
  payload_json = payload.to_json
  req.body = payload_json
  
  request_info = {
    method: "post",
    url: API_ENDPOINT,
    headers: {
      "RefId" => "1",
      "X-IBM-Client-Id" => CLIENT_ID,
      "X-IBM-Client-Secret" => CLIENT_SECRET,
      "CallerReqTime" => caller_req_time
    },
    body: payload_json
  }
  
  begin
    response = http.request(req)
    parse_response(response, request_info)
  rescue => e
    {
      status: :error,
      error_type: e.class.name,
      error_message: e.message,
      response: nil,
      payload: payload,
      request: request_info,
      created_at: Time.now.utc
    }
  end
end

# Parse the response
def parse_response(response, request_info)
  begin
    response_body = JSON.parse(response.body)
  rescue
    response_body = nil
  end
  
  {
    status: response.code.to_i >= 200 && response.code.to_i < 300 ? :success : :failure,
    payload: response_body,
    request: request_info,
    response: response,
    error_type: nil,
    error_message: nil,
    created_at: Time.now.utc
  }
end

# Populated with correct values from provided data
contract_number = "20582937828"
contract_start_date = "2025-07-01"
contract_end_date = "2028-06-30"
premise_id = "4004107974"
equipment_number = "25548785"
owner_id = "1015537713"
tenant_id = "1010214603"

# Create payload
payload = create_move_in_payload(
  contract_number, 
  contract_start_date, 
  contract_end_date, 
  premise_id, 
  equipment_number, 
  owner_id, 
  tenant_id
)

# Send request
result = send_move_in_request(payload)

# Output result
puts "Status: #{result[:status]}"
puts "Response:"
puts JSON.pretty_generate(result[:payload]) if result[:payload]

if result[:status] == :error
  puts "Error Type: #{result[:error_type]}"
  puts "Error Message: #{result[:error_message]}"
end