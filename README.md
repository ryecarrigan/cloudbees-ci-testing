# CloudBees CI disk throughput testing
These are the scripts used to generate test data for the disk throughput testing.

## Setup
The testing scripts use some common environment variables.

Make a copy of `.env.example` to `.env` and source it to set the environment variables:
```shell
export CBCI_FOLDER_COUNT=50
export CBCI_JOBS_PER_FOLDER=100
export CBCI_OUTPUT_DIR=items
export CBCI_TRIGGER_INTERVAL=60
export CBCI_TEST_TIME_IN_SECONDS=3600

export JENKINS_URL=""
export JENKINS_USER_ID=""
export JENKINS_API_TOKEN=""
```

The `CBCI_*` variables are optional and have configured defaults if unset.

## Steps
1. Set up the script configuration.
   1. Copy `.env.example` to `.env` and source it to set the environment variables.
   2. Create a test pipeline called `pipeline.groovy` that will be provided to the Pipeline jobs.
      * An example is provided in `pipeline.groovy.example` but please customize to meet the needs of your environment.
2. Create test jobs.
   1. Run `./create-item-yaml.sh` to generate the CasC item YAMLs from the test pipeline.
   2. Run `./create-items.sh` to POST the configuration YAMLs to the configured controller.
   3. Wait until all items are created. This may take a while depending on how many test jobs you are creating.
3. Run the tests.
   * Run `./build.sh` and wait!
   * The script will trigger a random job from the test jobs and then sleep for `CBCI_TRIGGER_INTERVAL` until the elapsed time exceeds `CBCI_TEST_TIME_IN_SECONDS`.



## Advanced
Stricter testing can be done by disabling certain plugins and features that perform periodic actions.

### Disabled processes
The following plugins and processes can be disabled to minimize periodic disk IO.

* Support bundle generation
  * Disabled with Java property `com.cloudbees.jenkins.support.SupportPlugin.AUTO_BUNDLE_PERIOD_HOURS=0` 

* Workspace cleanup thread
  * Disabled with Java property `hudson.model.WorkspaceCleanupThread.disabled=true` 

* Fingerprint cleanup
  * Disabled with CasC
    ```yaml
    unclassified:
      fingerprints:
        fingerprintCleanupDisabled: true
    ```

* Global build discarders
  * "Periodic background build discarder" task cannot be disabled entirely, but we can ensure the list of discarders is empty. This leaves the task iterating over all jobs but taking no action on them.
    ```yaml
    unclassified:
      buildDiscarders:
        configuredBuildDiscarders: []
    ```
    
* Plugin usage analyzer
  * Disabled through CasC
    ```yaml
    tool:
      cloudbeesPluginUsageAnalyzer:
        enabled: false
    ```

All other async tasks will continue to run.
