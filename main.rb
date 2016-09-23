require 'dotenv'
require 'salesforce_bulk'
require 'pp'
require 'savon'
require_relative 'sforce_wrapper'
Dotenv.load ".env"

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


pp fields

salesforce = SalesforceBulk::Api.new(ENV["SFDC_ID"], ENV["SFDC_PW"])
res = salesforce.query("Account", "select " + fields.join(",") + " from Account limit 3")
File.write('export.csv', fields.join(",") +" \n "+ res.result.raw)


s = SforceWrapper.new(ENV["WAVE_ID"], ENV["WAVE_PW"])

