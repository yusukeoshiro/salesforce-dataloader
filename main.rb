require 'dotenv'
require 'salesforce_bulk'
require 'pp'
require 'savon'
require 'Base64'
require 'JSON'
require_relative 'sforce_wrapper'
Dotenv.load ".env"

#FILE_MAX_SIZE = 5240
FILE_MAX_SIZE = 5242880


fields = [
"Id",
"AccountId",
"RecordTypeId",
"Name",
"StageName",
"Amount",
"CloseDate",
"Type",
"IsClosed",
"IsWon",
"CurrencyIsoCode",
"AmountConverted__c",
"Premier_Specialist__c",
"IsPremierUpsell__c",
"Premier_Status__c",
"Premier_Reason_for_Loss__c",
"Premier_Notes_Next_Steps__c",
"IsPremier_Attached__c",
"Owner.Name",
"Owner.UserRoleId",
"Owner.UserRole.Name",
"Owner.ManagerId",
"Owner.Manager.Name",
"Account.Name",
"RecordType.Name"
]

fields = [
	"id","name","createddate"
]


# EXTRACT DATA FROM SOURCE ORG
	salesforce = SalesforceBulk::Api.new(ENV["SFDC_ID"], ENV["SFDC_PW"])
	res = salesforce.query("Account", "select " + fields.join(",") + " from Account")
	File.delete('export.csv') if File.exist?('export.csv')

	fields.each_with_index do |field, i|
		fields[i] = '"'+ field +'"'
	end
	File.write('export.csv', fields.join(",") +"\n"+ res.result.raw)



# CONNECT TO WAVE INSTANCE
	s = SforceWrapper.new(ENV["WAVE_ID"], ENV["WAVE_PW"])

# SPLIT FILES INTO CHUNKS
	file = File.open("export.csv", "r")
	index_of_files = 0
	tmp = File.open(index_of_files.to_s, "a")	
	
	file.each do |line|
		tmp.puts line
		if tmp.size > FILE_MAX_SIZE
			p "index is: #{index_of_files}"
			tmp.close
			index_of_files = index_of_files + 1
			tmp = File.open(index_of_files.to_s, "a")
		end
	end
	file.close
	p index_of_files
	File.delete('export.csv') if File.exist?('export.csv')


# CREATE HEADER
	meta_json = Base64.encode64(File.read("export.json"))
	payload = {
		"Format" => "Csv",
		"EdgemartAlias" => "myTest",
		"MetadataJson" => meta_json,
		"Operation" => "Overwrite",
		"Action" => "None"
	}
	parent_record_id = s.insert_record( "InsightsExternalData", payload )

# CREATE LINES
	(index_of_files+1).times do |index|
		file_name = index.to_s
		payload = {
			"DataFile" => Base64.encode64(File.read(file_name)),
			"InsightsExternalDataId" => parent_record_id,
			"PartNumber" => index+1
		}
		s.insert_record( "InsightsExternalDataPart", payload )		
		File.delete(file_name)	
	end

# START PROCESSING
	
	payload = {
		"Action" => "Process"
	}
	s.update_record( "InsightsExternalData", parent_record_id, payload )



