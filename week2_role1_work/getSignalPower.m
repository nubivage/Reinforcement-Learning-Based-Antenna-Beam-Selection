function [powerDbm, info] = getSignalPower(txSite, rxSite, ...
    txAz, txEl, rxAz, rxEl, txArray, rxArray, rayModel, f, txPowerDbm, ...
    txHeading, rxHeading)
%GETSIGNALPOWER Ray-trace a link and calculate received power in dBm.
% Optional txHeading/rxHeading are global azimuth reference directions.
% Beam angles txAz/rxAz are steering offsets relative to those headings.
% Uses the same local-angle convention as the current Buildlinktable.m.
%
% Pr[dBm] = Pt[dBm] + Gtx[dBi] - PathLoss[dB] + Grx[dBi]
% Selects the finite-path-loss ray with minimum path loss.

powerDbm = -Inf;
info = struct('validPath',false,'pathLossDb',NaN,'txGainDb',NaN, ...
    'rxGainDb',NaN,'aodDeg',[NaN NaN],'aoaDeg',[NaN NaN], ...
    'phaseShiftDeg',NaN,'propagationDelaySec',NaN, ...
    'selectedPathIndex',NaN,'numRays',0,'rayType',"NO_PATH");

% Optional headings preserve compatibility with older callers.
if nargin < 12 || isempty(txHeading), txHeading = 0; end
if nargin < 13 || isempty(rxHeading), rxHeading = 0; end
wrap180 = @(x) mod(x + 180, 360) - 180;

rays = raytrace(txSite, rxSite, rayModel);
if isempty(rays) || isempty(rays{1}), return; end

paths = rays{1};
info.numRays = numel(paths);
loss = [paths.PathLoss];
good = isfinite(loss);
if ~any(good), return; end

candidateIndices = find(good);
[~,localIdx] = min(loss(good));
idx = candidateIndices(localIdx);
ray = paths(idx);

info.selectedPathIndex = idx;
info.pathLossDb = double(ray.PathLoss);
info.aodDeg = anglePair(ray.AngleOfDeparture);
info.aoaDeg = anglePair(ray.AngleOfArrival);
if isprop(ray,'PhaseShift'), info.phaseShiftDeg = double(ray.PhaseShift); end
if isprop(ray,'PropagationDelay')
    info.propagationDelaySec = double(ray.PropagationDelay);
end

% Convert global ray azimuths to local azimuths relative to array headings.
txLocalAz = wrap180(info.aodDeg(1) - txHeading);
rxLocalAz = wrap180(info.aoaDeg(1) - rxHeading);

wTx = steering_weights(txArray,f,txAz,txEl);
gt = pattern(txArray,f,txLocalAz,info.aodDeg(2), ...
    'Weights',wTx,'Type','directivity');

% Keep the same arrival-angle convention as Buildlinktable.m.
% If the table builder changes to reverse the arrival direction, update
% this function in the same way.
wRx = steering_weights(rxArray,f,rxAz,rxEl);
gr = pattern(rxArray,f,rxLocalAz,info.aoaDeg(2), ...
    'Weights',wRx,'Type','directivity');

info.txGainDb = double(gt(1));
info.rxGainDb = double(gr(1));
if ~isfinite(info.txGainDb) || ~isfinite(info.rxGainDb) || ...
        ~isfinite(info.pathLossDb)
    return;
end

powerDbm = txPowerDbm + info.txGainDb - info.pathLossDb + info.rxGainDb;
info.validPath = isfinite(powerDbm);
if ~info.validPath, powerDbm = -Inf; end
info.rayType = classifyRay(ray);
end

function a = anglePair(raw)
raw = double(raw(:));
if numel(raw)<2
    error('getSignalPower:InvalidAngles', ...
        'Ray angles need azimuth and elevation.');
end
a = raw(1:2).';
end

function label = classifyRay(ray)
label = "UNKNOWN";
props = properties(ray);
if any(strcmp(props,'Interactions'))
    try
        if isempty(ray.Interactions), label = "LOS"; else, label = "REFLECTION/OTHER"; end
    catch
    end
elseif any(strcmp(props,'NumInteractions'))
    try
        if ray.NumInteractions==0, label="LOS"; else, label="REFLECTION/OTHER"; end
    catch
    end
end
end
