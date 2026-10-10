
clear;
clc;

S = build_role1_scenario();

% Selected receive beam from the project reference angles
rxAz = -30;
rxEl = 0;

% Find the propagation ray
rays = raytrace(S.tx1, S.rx1, S.rayModel);
pathList = rays{1};
[~, idx] = min([pathList.PathLoss]);
ray = pathList(idx);

aoa = double(ray.AngleOfArrival(:));

% Direction from receiver toward source
sourceAz = mod(aoa(1) + 180 + 180, 360) - 180;
sourceEl = -aoa(2);

% Calculate weights for the selected beam
wRx = steering_weights( ...
    S.rxArray, S.cfg.f, rxAz, rxEl);

% Plot the receive pattern using those weights
figure;
pattern( ...
    S.rxArray, S.cfg.f, ...
    'Weights', wRx, ...
    'Type', 'directivity');

title('Receive Array Pattern with Selected Beam');

% Evaluate directivity toward the source
d = pattern( ...
    S.rxArray, S.cfg.f, ...
    sourceAz, sourceEl, ...
    'Weights', wRx, ...
    'Type', 'directivity');

fprintf('Source azimuth: %.3f degrees\n', sourceAz);
fprintf('Source elevation: %.3f degrees\n', sourceEl);
fprintf('Directivity toward source: %.3f dBi\n', d(1));