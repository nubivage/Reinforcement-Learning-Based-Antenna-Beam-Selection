function results = test_role1(S)
%TEST_ROLE1 Run small validation tests for Role 1.

cfg = S.cfg;

% Three deliberately different steering configurations.
testAngles = [ ...
     30 -30  -30   0;
      0 -30    0   0;
    -30 -30   30   0];

n = size(testAngles,1);

rxPower = zeros(n,1);
pathLoss = NaN(n,1);
txGain = NaN(n,1);
rxGain = NaN(n,1);
valid = false(n,1);

for k = 1:n
    a = testAngles(k,:);

    [rxPower(k), info] = getSignalPower( ...
        S.tx1, S.rx1, ...
        a(1), a(2), a(3), a(4), ...
        S.txArray, S.rxArray, S.rayModel, ...
        cfg.f, cfg.txPowerDbm);

    valid(k) = info.validPath;
    pathLoss(k) = info.pathLossDb;
    txGain(k) = info.txGainDb;
    rxGain(k) = info.rxGainDb;
end

results = table( ...
    testAngles(:,1), testAngles(:,2), ...
    testAngles(:,3), testAngles(:,4), ...
    rxPower, valid, pathLoss, txGain, rxGain, ...
    'VariableNames', { ...
    'TxAz','TxEl','RxAz','RxEl', ...
    'ReceivedPower_dBm','ValidPath', ...
    'PathLoss_dB','TxGain_dB','RxGain_dB'});

disp(results);

if ~any(valid)
    error("No valid Tx1 -> Rx1 ray was found.");
end

finitePower = rxPower(isfinite(rxPower));

if numel(finitePower) >= 2
    fprintf("\nReceived-power spread across tests: %.3f dB\n", ...
        max(finitePower)-min(finitePower));
end

fprintf("Role-1 basic validation completed.\n");
end
