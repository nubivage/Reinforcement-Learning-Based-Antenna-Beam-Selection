
clear;
clc;

S = build_role1_scenario();

rays = raytrace(S.tx1, S.rx1, S.rayModel);
pathList = rays{1};
[~, idx] = min([pathList.PathLoss]);
ray = pathList(idx);

aoa = double(ray.AngleOfArrival(:));

% Direction from receiver toward the source
sourceAz = mod(aoa(1) + 180 + 180, 360) - 180;
sourceEl = -aoa(2);

fprintf('Source direction: azimuth %.4f, elevation %.4f\n', ...
    sourceAz, sourceEl);

% Compare steering weights for the reference Rx steering angle
rxAz = -30;
rxEl = 0;

wOriginal = steering_weights( ...
    S.rxArray, S.cfg.f, rxAz, rxEl);

wReversed = steering_weights( ...
    S.rxArray, S.cfg.f, sourceAz, sourceEl);

% Evaluate both weight sets in the source direction
pOriginal = pattern( ...
    S.rxArray, S.cfg.f, sourceAz, sourceEl, ...
    'Weights', wOriginal, 'Type', 'directivity');

pReversed = pattern( ...
    S.rxArray, S.cfg.f, sourceAz, sourceEl, ...
    'Weights', wReversed, 'Type', 'directivity');

fprintf('Directivity with reference steering weights: %g dBi\n', ...
    pOriginal(1));

fprintf('Directivity with source-direction steering weights: %g dBi\n', ...
    pReversed(1));