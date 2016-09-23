require 'dotenv'
require 'salesforce_bulk'
require 'pp'
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

pp fields

salesforce = SalesforceBulk::Api.new(ENV["SFDC_ID"], ENV["SFDC_PW"])
res = salesforce.query("Account", "select id, name, createddate from Account limit 3")
puts res.result.records.inspect


File.write('export.csv', res.result.raw)
