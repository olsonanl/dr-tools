# Datarobot API tools

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