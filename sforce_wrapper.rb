class SforceWrapper
	attr_accessor :server_url, :session_id

	def initialize(username, password)
		path = "salesforce_partner_wsdl.xml"
		client = Savon.client(wsdl: path)
		response = client.call(:login, message: { "username"=>username, "password"=>password })
		response = response.to_hash
		self.session_id = response[:login_response][:result][:session_id]
		self.server_url = "https://"+URI.parse( response[:login_response][:result][:server_url] ).host
	end

	def insert_record( sobject, payload )
			
			url = "#{self.server_url}/services/data/v36.0/sobjects/#{sobject}/"
			uri = URI.parse(url)
			https = Net::HTTP.new(uri.host, uri.port)
			https.use_ssl = true
			req = Net::HTTP::Post.new(uri.request_uri)
			req["Content-Type"] = "application/json" 
			req["Authorization"] = "Bearer #{self.session_id}" 
			req.body = payload.to_json 
			res = https.request(req)
			p "***RESPONSE***"
			pp res.to_hash
			p "**************"
			return res.to_hash["location"][0].split('/')[-1]


		begin
			url = "#{self.server_url}/services/data/v36.0/sobjects/#{sobject}/"
			uri = URI.parse(url)
			https = Net::HTTP.new(uri.host, uri.port)
			https.use_ssl = true
			req = Net::HTTP::Post.new(uri.request_uri)
			req["Content-Type"] = "application/json" 
			req["Authorization"] = "Bearer #{self.session_id}" 
			req.body = payload.to_json 
			res = https.request(req)
			p "-----------response"
			pp res.to_hash
			return res.to_hash["location"][0].split('/')[-1]
		rescue Exception => e
			p "***************ERROR**************"
			p e.message
			return nil
		end
	end

	def update_record( sobject, record_id, payload )
		begin
			url = "#{self.server_url}/services/data/v36.0/sobjects/#{sobject}/#{record_id}"
			uri = URI.parse(url)
			https = Net::HTTP.new(uri.host, uri.port)
			https.use_ssl = true
			req = Net::HTTP::Patch.new(uri.request_uri)
			req["Content-Type"] = "application/json" 
			req["Authorization"] = "Bearer #{self.session_id}" 
			req.body = payload.to_json 
			res = https.request(req)
			return res.to_hash
		rescue Exception => e
			return nil
		end

	end

end