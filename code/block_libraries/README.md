# block_libraries

The ```DEGAS/code/block_libraries/``` directory contains custom Simulink blocks that can be used in end-to-end simulations. There are 6 basic libraries organized by type that contain different blocks that can be used in end-to-end simulations. Each library directory also contains the individual Simulink blocks that comprise each library, along with their associated wrapper classes and unit tests. The unit tests verify that each Simulink block works as intended.

`DEGAS_Toolbox.slx` can be used to access the basic libraries from one file.

Below is a brief description of each library and the blocks they contain:

1) controlLib: Contains blocks that control when the end-to-end simulation will stop
 * StopConditions: If the range or altitude difference between the ownship and intruder exceed a certain threshold, the simulation will stop. It is recommended that this block is in every end-to-end simulation between two aircraft.

2) dynamicsLib: Contains blocks that simulate the aircraft dynamics
 * BasicAircraftDynamics: Simulates the basic 6 degree-of-freedom dynamics of an aircraft. Aircraft dynamic performance constraints can be defined via the tunable parameters available in the class.

3) logicAndResponseLib: Contains blocks that generate trajectories
 * NominalTrajectory: Reads the event data from an 'event' .mat file and applies the events at the correct time step in the simulation. An event is a change to an aircraft's vertical rate, turn rate, or acceleration at a specific point in time. Events are defined by the standard encounter models located [here](https://github.com/mit-ll/em-overview). The EncounterModelEvents class located in /DEGAS/code/base_classes/ defines the properties and files used by the NominalTrajectory block.  

* TrackFollower: Reads trajectory data from a .txt file and overrides the current position and velocity of an aircraft in the simulation with the position and velocity read from the .txt file.

4) metricsLib: Contains blocks that collect metrics
 * CalcMinDist: Calculates the three-dimensional slant distance between the ownship and intruder.

 * CommonMetrics: Calculates various metrics, such as Horizontal Miss Distance, Vertical Miss Distance, Near Mid-Air Collision, etc. It is recommended that this block is in every end-to-end simulation.

 * SLoWC: Calculates Severity of Loss of Well Clear (defined in RTCA DO-365).

 * WellClearMetrics: Calculates if there is a loss of well clear between the ownship and intruder. Outputs 1 if there is a well clear violation, 0 otherwise. More information on the concept of well clear can be found [here](https://doi.org/10.2514/6.2015-0481).

5) signalsLib: Contains blocks that help generate or transform bus signals or other types of signals. In Simulink, a bus object is a single signal that carries multiple signals. Each signal in the bus can be accessed via a Bus Selector Simulink block.  
 * Coordinate Transformations: This subsystem contains coordinate transformations

   * cart2cyl: Converts from cartesian coordinates to cylindrical coordinates
   * cyl2cart: Converts from cylindrical coordinates to cartesian coordinates
   * LLA2ECEF: Converts from latitude, longitude, altitude (LLA) to Earth-centered, earth-fixed coordinates (ECEF)
   * ECEF2LLA: Converts from ECEF to LLA
   * cart2sph_degas: Converts from cartesian coordinates to spherical coordinates
   * sph2cart: Converts from spherical coordinates to cartesian coordinates

* AircraftState: This subsystem contains blocks that generate an AircraftState signal

   * AircraftStateFromPositions: Converts East, North, Up (ENU) to AircraftState and AircraftStateRate buses


* Bus Constructors: Constructs empty buses that can be used to make a desired signal

   * NullADSBBus: Creates an empty ADSB bus

   * NullAircraftEstimateBus: Creates an empty AircraftEstimate bus

   * NullAircraftStateBus: Creates an empty AircraftState bus

   * NullAircraftStateRateBus: Creates an empty AircraftStateRate bus

   * NullCommandBus: Creates an empty AircraftCommands bus

   * NullConstraintsBus: Creates an empty AircraftConstraints bus

   * NullCovarianceBus: Creates an empty CovarianceEstimate bus

   * NullEventsBus: Creates an empty EncounterModelEvents bus

   * NullLatLonAltBus: Creates an empty LatLonAltMeasurement bus

   * NullRadarSurveillanceBus: Creates an empty RadarSurveillance bus

   * NullStateEstimateBus: Creates an empty StateEstimate bus

   * NullTcasSurveillanceBus: Creates an empty TcasSurveillance bus


* Bus Converters: This subsystem contains blocks that convert a bus to a format that can be used by a top-level output

   * FlattenAircraftEstimateBus: Converts AircraftEstimate bus to a muxed signal


* Signal Filtering: This subsystem contains filters for signals

   * HysteresisFilter: Applies a hysteresis to the incoming signal

   * MofNFilter: Applies an M-of-N filter to an incoming signal


6) surveillanceLib: Contains blocks that can be used to represent sensors and trackers

 * EOIRParametricModel: This Simulink block models an EOIR sensor according to RTCA SC-228

 * PerfectSurveillance: This Simulink block models a sensor that has no error

 * SC228_AdsbModel: This Simulink block models an ADS-B sensor according to RTCA SC-228 (DO-365 Appendix Q)
   * There is an additional class `SC228_TrackedAdsbModel` that models an ADS-B sensor being used with a tracker. Tracker errors are modeled after DO-365 Table 2-20.


 * SC228_ActiveSurveillanceModel: This Simulink block models an Active Surveillance sensor according to RTCA SC-228 (DO-365 Appendix Q)
   * There is an additional class named `SC228_TrackedActiveSurveillanceModel` that models an Active Surveillance sensor being used with a tracker. Tracker errors are modeled after DO-365 Table 2-20.


 * OwnshipError: This Simulink block models a GPS/INS sensor according to RTCA SC-228 (DO-365 Appendix Q)

 * SC228_RadarModel: This Simulink block models an Radar sensor according to RTCA SC-228 (DO-365 Appendix Q)
   * There is an additional class named `SC228_TrackedRadarModel` that models an Radar sensor being used with a tracker. Tracker errors are modeled after DO-365 Table 2-20.


 * SimpleTrackedSurveillance: This Simulink block models tracked surveillance per RTCA SC-228 specifications

## Additional Notes

### Setters/Getters
Many classes in ```DEGAS/code/block_libraries/``` have functions that look like:

    set.v_ftps(obj, value)

or

    get.heading_rad( this )

(Both of these functions are from `BasicAircraftDynamics.m`)

These functions are known as setters and getters respectively. The purpose of these functions is to set or get the values that appear after the dot operator. In the examples above, the `v_ftps` field of the `BasicAircraftDynamics` class is being set and the `heading_rad` field of `BasicAircraftDynamics` is being retrieved. These functions don't have to be called explicitly, if there is end-to-end simulation object (`simObj`) with an instance of `BasicAircraftDynamics` (`ac1Dynamics`), then running "`simObj.ac1Dynamics.v_ftps = 1`" in the command line will call `set.v_ftps(obj, value)`. Similarly, running `simObj.ac1Dynamics.heading_rad` will call `get.heading_rad( this )`.

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do
 not necessarily reflect the views of the National Aeronautics and Space Administration .

© 2008 - 2020 Massachusetts Institute of Technology.

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above.
 Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.