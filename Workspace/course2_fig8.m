function [allData, scenario, sensors] = course2_fig8()
%figeightcourse - Returns sensor detections
%    allData = figeightcourse returns sensor detections in a structure
%    with time for an internally defined scenario and sensor suite.
%
%    [allData, scenario, sensors] = figeightcourse optionally returns
%    the drivingScenario and detection generator objects.

% Generated by MATLAB(R) 9.9 (R2020b) and Automated Driving Toolbox 3.2 (R2020b).
% Generated on: 07-Mar-2021 15:18:51

% Create the drivingScenario object and ego car
[scenario, egoVehicle] = createDrivingScenario;

% Create all the sensors
[sensors, numSensors] = createSensors(scenario);

allData = struct('Time', {}, 'ActorPoses', {}, 'ObjectDetections', {}, 'LaneDetections', {}, 'PointClouds', {});
running = true;
while running
    
    % Generate the target poses of all actors relative to the ego vehicle
    poses = targetPoses(egoVehicle);
    time  = scenario.SimulationTime;
    
    objectDetections = {};
    laneDetections   = [];
    ptClouds = {};
    isValidTime = false(1, numSensors);
    
    % Generate detections for each sensor
    for sensorIndex = 1:numSensors
        sensor = sensors{sensorIndex};
        [objectDets, numObjects, isValidTime(sensorIndex)] = sensor(poses, time);
        objectDetections = [objectDetections; objectDets(1:numObjects)]; %#ok<AGROW>
    end
    
    % Aggregate all detections into a structure for later use
    if any(isValidTime)
        allData(end + 1) = struct( ...
            'Time',       scenario.SimulationTime, ...
            'ActorPoses', actorPoses(scenario), ...
            'ObjectDetections', {objectDetections}, ...
            'LaneDetections', {laneDetections}, ...
            'PointClouds',   {ptClouds}); %#ok<AGROW>
    end
    
    % Advance the scenario one time step and exit the loop if the scenario is complete
    running = advance(scenario);
end

% Restart the driving scenario to return the actors to their initial positions.
restart(scenario);

% Release all the sensor objects so they can be used again.
for sensorIndex = 1:numSensors
    release(sensors{sensorIndex});
end

%%%%%%%%%%%%%%%%%%%%
% Helper functions %
%%%%%%%%%%%%%%%%%%%%

% Units used in createSensors and createDrivingScenario
% Distance/Position - meters
% Speed             - meters/second
% Angles            - degrees
% RCS Pattern       - dBsm

function [sensors, numSensors] = createSensors(scenario)
% createSensors Returns all sensor objects to generate detections

% Assign into each sensor the physical and radar profiles for all actors
profiles = actorProfiles(scenario);
sensors{1} = visionDetectionGenerator('SensorIndex', 1, ...
    'SensorLocation', [3.7 0], ...
    'MaxRange', 100, ...
    'DetectorOutput', 'Objects only', ...
    'Intrinsics', cameraIntrinsics([1814.81018227767 1814.81018227767],[320 240],[480 640]), ...
    'ActorProfiles', profiles);
sensors{2} = visionDetectionGenerator('SensorIndex', 2, ...
    'SensorLocation', [3.7 0], ...
    'MaxRange', 100, ...
    'DetectorOutput', 'Objects only', ...
    'Intrinsics', cameraIntrinsics([1814.81018227767 1814.81018227767],[320 240],[480 640]), ...
    'ActorProfiles', profiles);
numSensors = 2;

function [scenario, egoVehicle] = createDrivingScenario
% createDrivingScenario Returns the drivingScenario defined in the Designer

% Construct a drivingScenario object.
scenario = drivingScenario;

% Add all road segments
roadCenters = [19.9 -31.5 0;
    40.8 -25.5 0;
    61.034 0.36 0;
    60.18 49.2324 0;
    40.804 68.85 0;
    7.9 73.8 0;
    -5 77.4 0;
    -13.9 82.5 0;
    -25.2 91.8 0;
    -29.4428 100.98 0;
    -36.651 124.3 0;
    -31.7 149.816 0;
    -20.0525 165.571 0;
    -0.2872 176.941 0;
    20.3685 178.971 0;
    39.1137 173.288 0;
    60.1715 156.167 0;
    66.71 129.511 0;
    59.58 101.235 0;
    39.7651 82.0605 0;
    8.6 65 0;
    -22.1 42.5 0;
    -34.5 18.4 0;
    -26.7 -16.1 0;
    -11.6 -27.4 0;
    19.9 -31.5 0];
road(scenario, roadCenters, 'Name', 'Road');

% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [13.6 -31.5 0], ...
    'Mesh', driving.scenario.carMesh, ...
    'Name', 'Car');
waypoints = [13.6 -31.5 0;
    21.8 -31 0;
    32.2 -28.8 0;
    41.3 -25.3 0;
    52.5 -15.6 0;
    60.8 0.5 0;
    65.6 21.9 0;
    61.2 48.8 0;
    53 60.6 0;
    41.5 68.9 0;
    7.9 73.8 0;
    -5.6 78 0;
    -14.5 82.6 0;
    -25.7 92.4 0;
    -36.7 124.1 0;
    -31.6 150.3 0;
    -20 165.8 0;
    0 177.2 0;
    20.8 179.1 0;
    39.4 173.1 0;
    60.4 156 0;
    67.2 129.6 0;
    60.4 101.4 0;
    40.5 82 0;
    8.7 64.4 0;
    -9.2 53.8 0;
    -22.1 43.3 0;
    -30 29.5 0;
    -33.8 19.2 0;
    -35.4 3.5 0;
    -27.9 -14.9 0;
    -12.3 -27.8 0;
    12.7 -32.3 0];
speed = [30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30;30];
trajectory(egoVehicle, waypoints, speed);
