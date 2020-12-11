# base_classes

This directory contains MATLAB code that is not directly associated with the Simulink blocks located in `/DEGAS/code/block_libraries/`. The code contained in this directory is not expected to be used directly in the end-to-end simulation class (with a few exceptions). Instead, the classes in this directory are parent classes that the wrapper classes in `/DEGAS/code/block_libraries/` libraries are derived from.

A brief description of the classes in this directory are provided below:

### BasicSimulation

BasicSimulation contains the necessary functions and properties to run an end-to-end simulation created by the user.

### Block

Block is the main class that almost every wrapper class in `/DEGAS/code/block_libraries/` derives from. If the user creates a custom Simulink block and wants to use it in their end-to-end simulation, the associated Simulink block class must be derived from Block.

### DEGAS

DEGAS is the base class for the DEGAS simulation framework. It contains properties that are useful for converting units and functions that can be called by derived classes to perform actions before and after running an end-to-end simulation.

### EncounterModelEvents

The EncounterModelEvents class contains properties that dictate which events happen at what time in the simulation. This class is also used to populate the current directory with 'event' .mat files used by the end-to-end simulation. EncounterModelEvents is expected to be added to the end-to-end simulation as a property so that the directory where the end-to-end simulation is being run can be populated with 'event' .mat files.

### EncounterWarningCheck

The EncounterWarningCheck class contains functions that check simulated encounters for common errors - i.e. if the ownship alerted within the first 5 seconds of the encounter, if the ownship or intruder altitude went negative, etc. 

### MetricBlock

The MetricBlock class is the parent class for Simulink blocks that record metrics. Deriving a class from MetricBlock guarantees the recorded metrics are added to the `simObj.outcome` field.

### Simulation

The Simulation class populates various fields in the end-to-end simulation object, such as `results`, `results_nominal`, `estimates`, `analysis`, etc. The Simulation class also contains a plot function that creates a figure containing various plots of interest.

### SimulationAnalysis

The SimulationAnalysis class contains methods for examining the results of a simulation.

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do
 not necessarily reflect the views of the National Aeronautics and Space Administration .

© 2008 - 2020 Massachusetts Institute of Technology.

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above.
 Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.