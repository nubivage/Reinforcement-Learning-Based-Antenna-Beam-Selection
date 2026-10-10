function [powerDbm, info] = getSignalPower( ...
    txSite, rxSite, ...
    txAz, txEl, rxAz, rxEl, ...
    txArray, rxArray, rayModel, f, txPowerDbm)
%GETSIGNALPOWER Calculate received power for one Tx-Rx link.
%
% This is the central Role-1 function.
%
% Inputs:
%   txSite, rxSite       txsite/rxsite objects
%   txAz, txEl           Tx steering azimuth/elevation [deg]
%   rxAz, rxEl           Rx steering azimuth/elevation [deg]
%   txArray, rxArray     phased array objects
%   rayModel             ray-tracing propagationModel
%   f                    carrier frequency [Hz]
%   txPowerDbm           transmit power [dBm]
%
% Outputs:
%   powerDbm             received signal power [dBm]
%   info                 diagnostic structure

% Default diagnostic structure
info = struct( ...
    'validPath', false, ...
    'pathLossDb', NaN, ...
    'txGainDb', NaN, ...
    'rxGainDb', NaN, ...
    'aodDeg', [NaN NaN], ...
    'aoaDeg', [NaN NaN], ...
    'phaseShiftDeg', NaN, ...
    'propagationDelaySec', NaN, ...
    'selectedPathIndex', NaN, ...
    'numRays', 0);

powerDbm = -Inf;

% ------------------------------------------------------------
% 1. Ray trace the physical Tx -> Rx link
% ------------------------------------------------------------
rays = raytrace(txSite, rxSite, rayModel);

if isempty(rays) || isempty(rays{1})
    return;
end

pathList = rays{1};
info.numRays = numel(pathList);

% Select the path with the smallest path loss.
% This is a robust Week-1 choice for the strongest path.
pathLosses = [pathList.PathLoss];
[~, selectedIndex] = min(pathLosses);
ray = pathList(selectedIndex);

info.selectedPathIndex = selectedIndex;
info.pathLossDb = ray.PathLoss;

% ------------------------------------------------------------
% 2. Extract propagation directions
% ------------------------------------------------------------
aod = normalizeAnglePair(ray.AngleOfDeparture);
aoa = normalizeAnglePair(ray.AngleOfArrival);

info.aodDeg = aod;
info.aoaDeg = aoa;

% Optional ray fields
if isprop(ray, 'PhaseShift')
    info.phaseShiftDeg = ray.PhaseShift;
end

if isprop(ray, 'PropagationDelay')
    info.propagationDelaySec = ray.PropagationDelay;
end

% ------------------------------------------------------------
% 3. Tx beamforming gain at the ray's actual departure angle
% ------------------------------------------------------------
wTx = steering_weights(txArray, f, txAz, txEl);

gainTxDb = pattern( ...
    txArray, f, ...
    aod(1), aod(2), ...
    Weights=wTx, ...
    Type="powerdb");

% ------------------------------------------------------------
% 4. Rx beamforming gain at the ray's actual arrival angle
% ------------------------------------------------------------
wRx = steering_weights(rxArray, f, rxAz, rxEl);

gainRxDb = pattern( ...
    rxArray, f, ...
    aoa(1), aoa(2), ...
    Weights=wRx, ...
    Type="powerdb");

% Convert scalar outputs defensively.
gainTxDb = gainTxDb(1);
gainRxDb = gainRxDb(1);

info.txGainDb = gainTxDb;
info.rxGainDb = gainRxDb;
info.validPath = true;

% ------------------------------------------------------------
% 5. Link budget
%
% Pr[dBm] = Pt[dBm] + Gtx[dB] - PathLoss[dB] + Grx[dB]
% ------------------------------------------------------------
powerDbm = txPowerDbm + gainTxDb - ray.PathLoss + gainRxDb;

end


function ang = normalizeAnglePair(raw)
% Normalize a ray angle into [azimuth elevation].

raw = double(raw(:));

if numel(raw) < 2
    error('Unexpected ray angle format.');
end

ang = raw(1:2).';
end
