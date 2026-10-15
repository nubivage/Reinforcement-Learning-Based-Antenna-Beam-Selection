function weights = steering_weights(array, f, azimuthDeg, elevationDeg)
%STEERING_WEIGHTS Steering vector for the requested azimuth/elevation.
sv = phased.SteeringVector( ...
    SensorArray=array, PropagationSpeed=physconst('LightSpeed'));
weights = sv(f, [azimuthDeg; elevationDeg]);
end
