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


# CONNECT TO WAVE INSTANCE
	s = SforceWrapper.new(ENV["WAVE_ID"], ENV["WAVE_PW"])

# SPLIT FILES INTO CHUNKS
	file = File.open("extract.csv", "r")
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
	File.delete('extract.csv') if File.exist?('extract.csv')


# CREATE HEADER
	meta_json = Base64.encode64(File.read("extract.json"))
	payload = {
		"Format" => "Csv",
		"EdgemartAlias" => "Opps",
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



