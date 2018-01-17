# Condor utilities

Usage
-----

1. In `run.sh`, set all the parameters: the number of events per file, the location of the configuration text file (which describes each set of Pandora jobs), the location of a Pandora setup script, the number of files per job, whether to validate and some details about the validation. 

2. In the configuration text file (default location `config.txt`), write the description of the jobs to be run. The first row is the header row; each subsequent row represents a set of Pandora jobs to be run. The first four headings are `PandoraLocation`, `SettingsFileLocation`, `RecoOption` and `SampleLocation` (in that order), which must be filled in for every job. 

3. Further headings in the configuration file can be used to represent changes to make to the provided settings file using `sed`. To do this, replace the value in the settings file with a dummy name, surrounded by `£`s, then use the dummy name as the header. E.g. if we want to run a job with slicing on and slicing off, replace `<ShouldPerformSlicing>true</ShouldPerformSlicing>` in the settings file with `<ShouldPerformSlicing>£ShouldPerformSlicing£</ShouldPerformSlicing>`, then add a heading `ShouldPerformSlicing` to the config file, and set it as `true` or `false` for each row. Every row must have a value for every heading. If the heading was for one settings file and does not feature in another, then an arbitrary value can be put in the config file and `sed` will do nothing. This allows for easy parameter sweeps.

4. From the base directory, run `source run.sh` and the jobs will be run batch-wise. Concatenated root files are saved in `catroots`, any `stdout` from the validation script is saved in `results`. The results are numbered numerically by batch number, beginning at 0.

Tips/issues
-----------

- Running `source run.sh` deletes any files in `catroots`, `roots`, `results`, `xmls`, `xml_bases` etc., so move the results out of there if they're to be saved.

- To curate the jobs, it watches `condor_q` and counts the remaining jobs so it can concatenate them and run validation once they're all done. This means that running other condor jobs will cause this to wait until all the jobs are done, regardless of whether it started them or not. There's probably a way to get the job ID through the Python script and then use that to only look at the relevant jobs.
