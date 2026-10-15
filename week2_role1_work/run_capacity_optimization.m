
clear; clc;

%% Build scenario
S = build_role1_scenario();
cfg = S.cfg;

%% Site, array, and channel model
txSites = S.txSites;
rxSites = S.rxSites;
txArray = S.txArray;
rxArray = S.rxArray;
rayModel = S.rayModel;

%% Reference steering angles
angles = [30, 50, -30, 20];


%% Derive headings using the same convention as Buildlinktable
wrap180 = @(x) mod(x + 180, 360) - 180;

txHeadings = zeros(1,2);
rxHeadings = zeros(1,2);

for i = 1:2
    rays = raytrace(txSites{i}, rxSites{i}, rayModel);

    if isempty(rays) || isempty(rays{1})
        error('No paired ray found for Tx%d -> Rx%d.', i, i);
    end

    paths = rays{1};
    [~, k] = min([paths.PathLoss]);
    ray = paths(k);

    aod = double(ray.AngleOfDeparture(:)).';
    aoa = double(ray.AngleOfArrival(:)).';

    txHeadings(i) = aod(1);
    rxHeadings(i) = aoa(1);
end

%% Define received-power function using paired-ray headings
wrap180 = @(x) mod(x + 180, 360) - 180;

powerFcn = @(i,j,angTx,angRx) receivedPowerW( ...
    txSites{i}, rxSites{j}, ...
    wrap180(angTx - txHeadings(i)), cfg.txElevation, ...
    wrap180(angRx - rxHeadings(j)), cfg.rxElevation, ...
    txArray, rxArray, rayModel, ...
    cfg.f, cfg.txPowerDbm, ...
    txHeadings(i), rxHeadings(j));


%% Calculate capacity
C = totalCapacity(angles, powerFcn);

fprintf('\n===== REFERENCE CAPACITY CHECK =====\n');
fprintf('Current capacity: %.6f Gbps\n', C/1e9);
fprintf('Week-1 target: %.6f Gbps\n', cfg.referenceCapacityGbps);

%% Received power matrix
P = zeros(2,2);

fprintf('\n===== RECEIVED POWERS =====\n');

for i = 1:2
    for j = 1:2
        P(i,j) = powerFcn(i,j,angles(i),angles(j+2));

        if P(i,j) > 0
            pDbm = 10*log10(P(i,j)*1000);
        else
            pDbm = -Inf;
        end

        fprintf('Tx%d -> Rx%d: %.6e W, %.2f dBm\n', ...
            i, j, P(i,j), pDbm);
    end
end

%% SINR calculation
B = 400e6;
noiseW = physconst('Boltzmann') * cfg.noiseTemperatureK * B;

fprintf('\nThermal noise: %.2f dBm\n', 10*log10(noiseW*1000));

for j = 1:2
    wanted = P(j,j);
    interference = sum(P(:,j)) - wanted;
    sinr = wanted / (noiseW + interference);

    fprintf('Rx%d SINR: %.2f dB\n', j, 10*log10(max(sinr,realmin)));
end

%% Local function
function powerW = receivedPowerW( ...
    txSite, rxSite, txAz, txEl, rxAz, rxEl, ...
    txArray, rxArray, rayModel, f, txPowerDbm, ...
    txHeading, rxHeading)

    [powerDbm, info] = getSignalPower( ...
        txSite, rxSite, txAz, txEl, rxAz, rxEl, ...
        txArray, rxArray, rayModel, f, txPowerDbm, ...
        txHeading, rxHeading);

    if ~info.validPath || ~isfinite(powerDbm)
        powerW = 0;
    else
        powerW = 10.^((powerDbm - 30)/10);
    end
end
