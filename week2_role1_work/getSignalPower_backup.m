function [powerDbm, info] = getSignalPower(txSite, rxSite, ...
    txAz, txEl, rxAz, rxEl, txArray, rxArray, rayModel, f, txPowerDbm)
%GETSIGNALPOWER Ray-trace a link and calculate received power in dBm.
% Selects the minimum-path-loss ray (not coherent multipath combining).
% Pr[dBm] = Pt[dBm] + Gtx[dBi] - PL[dB] + Grx[dBi].
powerDbm = -Inf;
info = struct('validPath',false,'pathLossDb',NaN,'txGainDb',NaN, ...
    'rxGainDb',NaN,'aodDeg',[NaN NaN],'aoaDeg',[NaN NaN], ...
    'phaseShiftDeg',NaN,'propagationDelaySec',NaN, ...
    'selectedPathIndex',NaN,'numRays',0,'rayType',"NO_PATH");

rays = raytrace(txSite, rxSite, rayModel);
if isempty(rays) || isempty(rays{1})
    return;
end
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
if isprop(ray,'PropagationDelay'), info.propagationDelaySec = double(ray.PropagationDelay); end

wTx = steering_weights(txArray,f,txAz,txEl);
gt = pattern(txArray,f,info.aodDeg(1),info.aodDeg(2), ...
    'Weights',wTx,'Type','directivity');
% AoA describes propagation arriving at the receiver. Evaluate receive
% directivity toward the source, i.e. reverse azimuth and elevation.
rxSourceAz = mod(info.aoaDeg(1)+180+180,360)-180;
rxSourceEl = -info.aoaDeg(2);
wRx = steering_weights(rxArray,f,rxAz,rxEl);
gr = pattern(rxArray,f,rxSourceAz,rxSourceEl, ...
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
% Classify selected ray as LOS using the path's interaction metadata where
% available. Keep UNKNOWN rather than infer LOS solely from angles.
info.rayType = classifyRay(ray);
end

function a = anglePair(raw)
raw = double(raw(:));
if numel(raw)<2, error('getSignalPower:InvalidAngles','Ray angles need azimuth and elevation.'); end
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
