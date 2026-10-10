
function [powerDbm, info] = getSignalPower( ...
    txSite, rxSite, ...
    txAz, txEl, rxAz, rxEl, ...
    txArray, rxArray, rayModel, f, txPowerDbm)
%GETSIGNALPOWER Calculate received power for one Tx-Rx link.
%
% Angles are in degrees.
% Received power = Tx power + Tx gain - path loss + Rx gain.

    powerDbm = -Inf;

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

    %% 1. Trace propagation paths
    rays = raytrace(txSite, rxSite, rayModel);

    if isempty(rays) || isempty(rays{1})
        warning('getSignalPower:NoPath', ...
            'No propagation path was found between Tx and Rx.');
        return;
    end

    pathList = rays{1};
    info.numRays = numel(pathList);

    %% 2. Select the path with minimum path loss
    pathLosses = [pathList.PathLoss];
    [~, selectedIndex] = min(pathLosses);

    ray = pathList(selectedIndex);

    info.selectedPathIndex = selectedIndex;
    info.pathLossDb = ray.PathLoss;

    %% 3. Obtain ray departure and arrival angles
    aod = normalizeAnglePair(ray.AngleOfDeparture);
    aoa = normalizeAnglePair(ray.AngleOfArrival);

    info.aodDeg = aod;
    info.aoaDeg = aoa;

    if isprop(ray, 'PhaseShift')
        info.phaseShiftDeg = ray.PhaseShift;
    end

    if isprop(ray, 'PropagationDelay')
        info.propagationDelaySec = ray.PropagationDelay;
    end

    %% 4. Calculate transmit array response
    wTx = steering_weights(txArray, f, txAz, txEl);

    txPattern = pattern( ...
        txArray, f, ...
        aod(1), aod(2), ...
        'Weights', wTx, ...
        'Type', 'directivity');

    gainTxDb = txPattern(1);

    %% 5. Reverse arrival direction for receive array
    % The ray's arrival angles describe the incoming propagation
    % direction. The receive array response is evaluated toward
    % the source, i.e. the opposite direction.
    rxPatternAz = mod(aoa(1) + 360, 360);
    rxPatternAz = mod(rxPatternAz + 180 + 180, 360) - 180;
    rxPatternEl = -aoa(2);

    %% 6. Calculate receive array response
    wRx = steering_weights(rxArray, f, rxAz, rxEl);

    rxPattern = pattern( ...
        rxArray, f, ...
        rxPatternAz, rxPatternEl, ...
        'Weights', wRx, ...
        'Type', 'directivity');

    gainRxDb = rxPattern(1);

    %% 7. Store gains
    info.txGainDb = gainTxDb;
    info.rxGainDb = gainRxDb;

    %% 8. Validate gain values
    if ~isfinite(gainTxDb) || ~isfinite(gainRxDb)
        warning('getSignalPower:InvalidGain', ...
            ['Antenna gain is not finite. Check steering weights, ', ...
             'array orientation, and ray angle conventions.']);
        return;
    end

    %% 9. Calculate received power in dBm
    powerDbm = txPowerDbm ...
             + gainTxDb ...
             - ray.PathLoss ...
             + gainRxDb;

    info.validPath = true;

end


function ang = normalizeAnglePair(raw)
% Convert ray angles to a row vector [azimuth elevation].

    raw = double(raw(:));

    if numel(raw) < 2
        error('getSignalPower:InvalidRayAngles', ...
            'Ray angles must contain azimuth and elevation.');
    end

    ang = raw(1:2).';

end