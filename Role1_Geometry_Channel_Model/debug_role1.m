
clear;
clc;

S = build_role1_scenario();

% Generate the ray-tracing paths
rays = raytrace(S.tx1, S.rx1, S.rayModel);

if isempty(rays) || isempty(rays{1})
    error('No ray-tracing path found.');
end

% Select the path with minimum path loss
pathList = rays{1};
[~, idx] = min([pathList.PathLoss]);
ray = pathList(idx);

% Display the basic information
disp('Carrier frequency (Hz):');
disp(S.cfg.f);

disp('Transmit array element:');
disp(S.txArray.Element);

disp('Receive array element:');
disp(S.rxArray.Element);

disp('Ray departure angles:');
disp(ray.AngleOfDeparture);

disp('Ray arrival angles:');
disp(ray.AngleOfArrival);

% Test the receive array without steering weights
aoa = double(ray.AngleOfArrival(:));

rxDirectivity = pattern( ...
    S.rxArray, S.cfg.f, ...
    aoa(1), aoa(2), ...
    'Type', 'directivity');

disp('Receive directivity without steering weights:');
disp(rxDirectivity);

% Test the transmit array without steering weights
aod = double(ray.AngleOfDeparture(:));

txDirectivity = pattern( ...
    S.txArray, S.cfg.f, ...
    aod(1), aod(2), ...
    'Type', 'directivity');

disp('Transmit directivity without steering weights:');
disp(txDirectivity);