#medications_client rubygem
require 'httparty'
 
module Caller
	def self.post(url, request_body, headers)
	  puts "DRFIRST: POST #{url}"
	  HTTParty.post(url, body: request_body, headers: {})
	end
end

class SingleSignOnRequestService

	def initialize()
		@sso_gateway_url = 'https://gxrqhkeshk.execute-api.us-east-1.amazonaws.com/drfirst-sso-dev/sso-tokens' #TODO add url to .env and read from there
	end	

	def create_sso_request(rcopia_portal_system_name, rcopia_practice_user_name, rcopia_user, requested_service, rcopia_patient, secret_key)
		return SingleSignOnRequest.build(rcopia_portal_system_name, 
			rcopia_practice_user_name, 
			rcopia_user['id'], 
			rcopia_user['external_id'], 
			requested_service['service'], 
			requested_service['action'], 
			requested_service['startup_screen'], 
			rcopia_patient['id'], 
			rcopia_patient['external_id'], 
			secret_key)
	end

	def sso_login(rcopia_portal_system_name, rcopia_practice_user_name, rcopia_user, requested_service, rcopia_patient, secret_key) 
		single_sign_on_request = create_sso_request(rcopia_portal_system_name, rcopia_practice_user_name, rcopia_user, requested_service, rcopia_patient, secret_key)
		body = (single_sign_on_request.to_h.to_json)
		response = Caller.post(@sso_gateway_url, body, nil)
		#puts response; 	
		return response
	end
end

class SingleSignOnRequest < Struct.new(:rcopia_portal_system_name, 
	:rcopia_practice_user_name, 
	:rcopia_user_id, 
	:rcopia_user_external_id, 
	:service, 
	:action, 
	:startup_screen, 
	:rcopia_patient_id, 
	:rcopia_patient_external_id, 
	#TODO add 'time' field if required
	:secret_key)

	def initialize(*)
	      super
	      self.service ||= 'rcopia' #TODO create constant
	      self.action ||= 'login' #TODO create constant
	      each { |value| raise ArgumentError if value.nil? }
	end

	# TODO add 'time' field if required 
	def self.build(rcopia_portal_system_name, rcopia_practice_user_name, rcopia_user_id, rcopia_user_external_id, service, action, startup_screen, rcopia_patient_id, rcopia_patient_external_id, secret_key) 
		new(rcopia_portal_system_name, rcopia_practice_user_name, rcopia_user_id, rcopia_user_external_id, service, action, startup_screen, rcopia_patient_id, rcopia_patient_external_id, secret_key)
	end
end

#EMR
class DrFirstSSO
	
	attr_reader :patient_id, :startup_screen

	def self.send_sso_request(patient_id, startup_screen)
		sso_request_instance = new(patient_id, startup_screen)
		sso_response = SingleSignOnRequestService.new.
		sso_login(sso_request_instance.get_rcopia_portal_system_name,
		sso_request_instance.get_rcopia_practice_user_name,
		sso_request_instance.get_user_info,
		sso_request_instance.get_requested_service_info,
		sso_request_instance.get_patient_info,
		sso_request_instance.get_secret_key)
		puts sso_response
	end

	def initialize(patient_id, startup_screen)
		@patient_id = patient_id
		@startup_screen = startup_screen
	end

	def get_user_info
		#TODO add code to retrieve rcopia user information
		rcopia_user_info = {
		'id' => 'ahogue',
		'external_id' => 'provider1_ki5212'		
		} 
		return rcopia_user_info
	end

	def get_patient_info
		#TODO remove hardcoding
		rcopia_patient_info = {
		'id' => '26152340431',
		'external_id' => 'abingdonperseus'
		}
		return rcopia_patient_info
	end

	def get_requested_service_info
		#TODO remove hardcoding
		requested_rcopia_service_info = {
		'service'=> 'rcopia',
		'action' => 'login',
		'startup_screen' => self.startup_screen
		}
		return requested_rcopia_service_info
	end

	def get_secret_key
		#TODO remove hardcoding
		secret_key = 'Kipu2022!'
		return secret_key
	end

	def get_rcopia_portal_system_name
		#TODO remove hardcoding
		rcopia_portal_system_name = 'avendor4888'
		return rcopia_portal_system_name
	end

	def get_rcopia_practice_user_name
		#TODO remove hardcoding
		rcopia_practice_user_name = 'ki5212'
		return rcopia_practice_user_name
	end
end

#dummy entry point 
def x 
	DrFirstSSO.send_sso_request("1234","patient")
end



