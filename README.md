# Datarobot API tools

This repository contains a simple set of tools for dealing with the DataRobot API.

## Configuration

The scripts shouldn't require any configuration except to either put the directory containing
them in your PATH, or invoking them using their full pathname.

## Dependencies

These tools use a few perl modules that might not be part of a standard build. You should
be able to load them from CPAN:

-  JSON::XS
-  Getopt::Long::Descriptive
-  Text::Table
-  LWP::Protocol::socks

(the latter is required for SOCKS proxy access; see below).

The Perl build that is included in the [PATRIC](https://patricbrc.org) command line interface 
package includes the necessary dependencies. It can be downloaded 
[here](https://github.com/PATRIC3/PATRIC-distribution/releases). 

If you need SOCKS support you will likely need to add that library:

```
  cpanm LWP::Protocol::socks
```

## Network access

These tools assume access to the IP address space that the server is running in. If
you wish to use the tools from a network that is outside the firewall, you can 
use `ssh` to create a SOCKS proxy:

```
  ssh -D 32000 login.mcs.anl.gov
```

Leave that command running in a window. You won't need to use it any more.

In the shell where you are going to run the tools, set this environment variable:

```
  export DR_PROXY=socks://localhost:32000
```

where the number in the proxy URL matches the port number you provided in the ssh command.


## Command line tools

The DataRobot tools require an authentication token. The `dr-login` script creates
a token that is stored in a file .datarobot_token in your home directory:

```
  $ dr-login usernamame password
  Got {"apiToken": "9XXXX-YYYYY"}
```

The list of active projects can be enumerated using `dr-list-projects`:

```
  $ dr-list-projects
  ID                       Name                                       Filename
  XXXXXXXXXXXXXXXXXXXXXXXX lesion_bio                                 lesion_data.csv
  XXXXXXXXXXXXXXXXXXXXXXXX lesion_bio_snp                             lesion_data.csv
  XXXXXXXXXXXXXXXXXXXXXXXX lesion_bio_snp_pmh_arrED_demo_subst_arrGCS lesion_data.csv
  XXXXXXXXXXXXXXXXXXXXXXXX severe_cluter_outcome                      severe_cluster_data.csv
  XXXXXXXXXXXXXXXXXXXXXXXX severe_clusters_no_mild                    severe_cluster_data.csv
  XXXXXXXXXXXXXXXXXXXXXXXX severe_clusters                            severe_cluster_data.csv
  XXXXXXXXXXXXXXXXXXXXXXXX api-test-tsb                               GDSC.193.tsv.binary.upload.robot.csv
  [...]
```

If you add a parameter to the `dr-list-projects` command it will limit the output to projects
with a name matching that parameter:

```
  $ dr-list-projects ANL
  ID                       Name                  Filename
  XXXXXXXXXXXXXXXXXXXXXXXX ANL PTSD 3.0 (Manual) PTSD_6mo_no_leak.csv
  XXXXXXXXXXXXXXXXXXXXXXXX ANL PTSD 2.0          PTSD_6mo_no_leak.csv
  XXXXXXXXXXXXXXXXXXXXXXXX ANL Demo PTSD 1.0     TRACKTBI_Pilot_DEID_02.22.18v2.csv
  XXXXXXXXXXXXXXXXXXXXXXXX ANL Demo 3.0          TRACKTBI_Pilot_DEID_02.22.18v2.csv
  XXXXXXXXXXXXXXXXXXXXXXXX ANL Demo 2.0          TRACKTBI_Pilot_DEID_02.22.18v2.2.csv
  XXXXXXXXXXXXXXXXXXXXXXXX ANL Demo 1.0          TRACKTBI_Pilot_DEID_02.22.18v2.2.csv
```

You can check the status of a particular project using the `dr-project-status` command:

```
  $ dr-project-status XXXXXXXXXXXXXXXXXXXXXXXX 
  {
     "stage" : "modeling",
     "stageDescription" : "Ready for modeling",
     "autopilotDone" : true
  }
```

You can upload data and create a new project using the `dr-create-project` command:

```
  $ perl dr-create-project x.csv bob-test-5
  Check status: http://140.221.10.250/api/v2/status/XX-YY-ZZ-QQ/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-10T21:00:59.637475Z"}
  Check status: http://140.221.10.250/api/v2/status/XX-YY-ZZ-QQ/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-10T21:00:59.637475Z"}
  Check status: http://140.221.10.250/api/v2/status/XX-YY-ZZ-QQ/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-10T21:00:59.637475Z"}
  Check status: http://140.221.10.250/api/v2/status/XX-YY-ZZ-QQ/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-10T21:00:59.637475Z"}
  Check status: http://140.221.10.250/api/v2/status/XX-YY-ZZ-QQ/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-10T21:00:59.637475Z"}
  Check status: http://140.221.10.250/api/v2/status/XX-YY-ZZ-QQ/
  Status: {"id": "XXXXXXXXXXXXXXXXXX", "projectName": "bob-test-5", "fileName": "x.csv", "stage": "aim", "autopilotMode": null, "created": "2018-04-10T21:01:04.941835Z", "target": null, "metric": null, "partition": {"datetimeCol": null, "cvMethod": null, "validationPct": null, "reps": null, "cvHoldoutLevel": null, "holdoutLevel": null, "userPartitionCol": null, "validationType": null, "trainingLevel": null, "partitionKeyCols": null, "holdoutPct": null, "validationLevel": null}, "recommender": {"recommenderItemId": null, "isRecommender": null, "recommenderUserId": null}, "advancedOptions": {"scaleoutModelingMode": "disabled", "responseCap": null, "downsampledMinorityRows": null, "downsampledMajorityRows": null, "blueprintThreshold": null, "seed": null, "weights": null, "smartDownsampled": false, "majorityDownsamplingRate": null}, "positiveClass": null, "maxTrainPct": null, "holdoutUnlocked": false, "targetType": null}
  Project ID found: XXXXXXXXXXXXXXXXXX
  Created: XXXXXXXXXXXXXXXXXX
```

A model job can be started with the `dr-create-model-job` command. With the `-w` or `--await-completion` flags
command will repeated query DataRobot to monitor the job's status, exiting when the job is complete
(or has shown an error).

```
  bash-3.2$ ./dr-start-model-job -w 5ace55475a28ff195dac32be citrus
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"status": "RUNNING", "message": "", "code": 0, "created": "2018-04-11T18:35:23.974133Z"}
  Check status: http://140.221.10.250/api/v2/status/e8db6fd6-c69f-4a58-bdfd-4b142c373e2d/
  Status: {"id": "5ace55475a28ff195dac32be", "projectName": "bob.fruit3", "fileName": "x.csv", "stage": "modeling", "autopilotMode": 0, "created": "2018-04-11T18:34:53.115904Z", "target": "citrus", "metric": "LogLoss", "partition": {"datetimeCol": null, "cvMethod": "stratified", "validationPct": null, "reps": 5, "cvHoldoutLevel": null, "holdoutLevel": null, "userPartitionCol": null, "validationType": "CV", "trainingLevel": null, "partitionKeyCols": null, "holdoutPct": 20.0, "validationLevel": null}, "recommender": {"recommenderItemId": null, "isRecommender": null, "recommenderUserId": null}, "advancedOptions": {"scaleoutModelingMode": "disabled", "responseCap": false, "downsampledMinorityRows": null, "downsampledMajorityRows": null, "blueprintThreshold": null, "seed": null, "weights": null, "smartDownsampled": false, "majorityDownsamplingRate": null}, "positiveClass": 1.0, "maxTrainPct": 63.889, "holdoutUnlocked": false, "targetType": "Binary"}
```  

The state of model jobs and models may be enumerate with the `dr-list-model-jobs` and `dr-list-models` commands.