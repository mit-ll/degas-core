# testing

Contains code that allows the user to run the unit test master script. To execute the unit test master script, fill out the appropriate variables in `RUN_allUnitTests_script.m` and execute the script.

**Note:** The unit tests for the sensors located in `/DEGAS/code/block_libraries/basic_libraries/surveillanceLib/` are probability based unit tests, so there is a chance that the unit test may fail due to the standard deviation of the noise exceeding some threshold. In these cases, it is recommended that the unit test be rerun multiple times to ensure that the failure was due to random variation and not an issue with the implementation.

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do
 not necessarily reflect the views of the National Aeronautics and Space Administration .

© 2008 - 2020 Massachusetts Institute of Technology.

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above.
 Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.
