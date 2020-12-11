# integration_tests

Contains tests that the user can perform to verify that the various Simulink models and blocks are working as intended.

To check to see if the `NominalEncounter.slx` model and `DAAEncounter.slx` model are working as intended, the user should execute the script `RUN_integration_test_nom_daa.m`. This integration test should be run before any changes are make to the `NominalEncounter.slx` and `DAAEncounter.slx` Simulink models.

To check to see if the sensors in `surveillanceLib.slx`, the pilot model, and the DAIDALUS algorithm are working as intended, the user should execute the script `RUN_integration_test_all_sensors.m`. This integration test should be run before any changes are made to the DAIDALUS Simulink Interface code, the UAS Pilot model, or the sensor models located in `surveillanceLib.slx`.

## Contained Directories

* integrationTestEncounter: Contains the encounter used in the integration tests.
* savedResults: Contains the expected/truth results for the `RUN_integration_test_nom_daa.m` and `RUN_integration_test_all_sensors.m` scripts.

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do
 not necessarily reflect the views of the National Aeronautics and Space Administration .

© 2008 - 2020 Massachusetts Institute of Technology.

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above.
 Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.