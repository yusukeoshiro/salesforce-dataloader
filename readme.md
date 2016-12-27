# Salesforce Wave Dataloader

I've written a simple ruby script to load a csv file to wave analytics instance using the standard API provided by salesforce.

In order for this to work:

* Create .env file containing the username and the password of the target wave instance (WAVE_ID and WAVE_PW)
* Place the source csv file at the root path of the app (Make sure it is called extract.csv)
* Place the metadata file (in json) at the root path of the app (Make sure it is called extract.json)

