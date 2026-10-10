
clear;
clc;

S = build_role1_scenario();

rays = raytrace(S.tx1, S.rx1, S.rayModel);
pathList = rays{1};
[~, idx] = min([pathList.PathLoss]);
ray = pathList(idx);

aoa = double(ray.AngleOfArrival(:));
az = aoa(1);
el = aoa(2);

fprintf('Original arrival azimuth: %.4f degrees\n', az);
fprintf('Original arrival elevation: %.4f degrees\n\n', el);

% Test the receive array at several directions
testAngles = [
    az,      el;
    az-180,  el;
    -az,     el;
    0,       0;
    90,      0;
    -90,     0;
    180,     0;
    0,      30;
    0,     -30
];

fprintf('Receive array directivity tests:\n');

for k = 1:size(testAngles,1)
    testAz = testAngles(k,1);
    testEl = testAngles(k,2);

    % Keep azimuth within -180 to 180 degrees
    testAz = mod(testAz + 180, 360) - 180;

    d = pattern( ...
        S.rxArray, S.cfg.f, ...
        testAz, testEl, ...
        'Type', 'directivity');

    fprintf('Az = %8.3f, El = %8.3f -> %g dBi\n', ...
        testAz, testEl, d(1));
end

fprintf('\nReceive array configuration:\n');
disp(S.rxArray);

fprintf('\nReceive array element configuration:\n');
disp(S.rxArray.Element);