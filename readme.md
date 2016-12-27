# Salesforce Wave Dataloader

I've written a simple ruby script to load a csv file to wave analytics instance using the standard API provided by salesforce.

In order for this to work:

* Create .env file containing the username and the password of the target wave instance (WAVE_ID and WAVE_PW)
* Place the source csv file at the root path of the app (Make sure it is called extract.csv)
* Place the metadata file (in json) at the root path of the app (Make sure it is called extract.json)

### If you making this run in conjunction with dataloader
You will need to build dataloader. Follow the instruction on this repo. [link](https://github.com/forcedotcom/dataloader). 

Hint:
* Encrypt your password using the provided tool
* Create process-conf.xml file that looks like the one in sample folder

---------------
Refer to this sample shell script and modify as required.

```
# build dataloader
git clone https://github.com/forcedotcom/dataloader.git
cd dataloader
git submodule init
git submodule update
mvn clean package -DskipTests

# install ruby script
git clone https://github.com/yusukeoshiro/salesforce-dataloader.git
cd salesforce-dataloader
touch .env
bundle install

# encrypt your password (adjust the version number accordingly)
java -cp ~/dataloader/target/dataloader-38.0.0-uber.jar com.salesforce.dataloader.security.EncryptionUtil -e PASSWORD

# run dataloader for download and then run ruby script for upload (adjust the version number accordingly)
java -cp ~/dataloader/target/dataloader-38.0.0-uber.jar -Dsalesforce.config.dir="PATH_TO_PROCESS_CONF_XML" com.salesforce.dataloader.process.ProcessRunner process.name=PROCESS_NAME
cp PATH_TO_EXPORTED_CSV_FILE/extract.csv PATH_TO_RUBY_SCRIPT_ROOT/salesforce-dataloader/extract.csv
cd PATH_TO_RUBY_SCRIPT_ROOT/salesforce-dataloader/
ruby main.rb
```
