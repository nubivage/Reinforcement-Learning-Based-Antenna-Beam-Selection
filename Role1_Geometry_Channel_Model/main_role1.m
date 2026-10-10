%% MAIN_ROLE1
% Complete demonstration of Role 1:
% Geometry + arrays + steering + ray tracing + received power

clear;
clc;
close all;

fprintf("=============================================\n");
fprintf(" ROLE 1 - GEOMETRY & CHANNEL MODEL\n");
fprintf("=============================================\n\n");

% Build scenario
S = build_role1_scenario();
cfg = S.cfg;

fprintf("Carrier frequency : %.2f GHz\n", cfg.f/1e9);
fprintf("Wavelength        : %.6f m\n", cfg.lambda);
fprintf("Tx power          : %.2f W = %.3f dBm\n", ...
    cfg.txPowerW, cfg.txPowerDbm);

fprintf("\nTx1 = [%.6f, %.6f, %.1f m]\n", cfg.tx1);
fprintf("Tx2 = [%.6f, %.6f, %.1f m]\n", cfg.tx2);
fprintf("Rx1 = [%.6f, %.6f, %.1f m]\n", cfg.rx1);
fprintf("Rx2 = [%.6f, %.6f, %.1f m]\n", cfg.rx2);

fprintf("\nTx array = %d x %d URA\n", cfg.txRows, cfg.txCols);
fprintf("Rx array = %d x %d URA\n", cfg.rxRows, cfg.rxCols);
fprintf("Spacing  = lambda/2 = %.6f m\n", cfg.lambda/2);

fprintf("\nRay model = SBR, max reflections = %d\n", ...
    cfg.maxReflections);

% Visualize array pattern / steering
plot_role1_steering(S.txArray, cfg.f);

% Validate getSignalPower
fprintf("\nRunning getSignalPower validation...\n");
results = test_role1(S);

% Demonstrate the exact reference angles from the project plan
fprintf("\n=============================================\n");
fprintf(" REFERENCE-ANGLE HANDOFF TEST\n");
fprintf("=============================================\n");

[p, info] = getSignalPower( ...
    S.tx1, S.rx1, ...
    cfg.referenceTx1Az, cfg.txElevation, ...
    cfg.referenceRx1Az, cfg.rxElevation, ...
    S.txArray, S.rxArray, S.rayModel, ...
    cfg.f, cfg.txPowerDbm);

fprintf("Tx1 azimuth = %g deg\n", cfg.referenceTx1Az);
fprintf("Rx1 azimuth = %g deg\n", cfg.referenceRx1Az);
fprintf("Received power = %.3f dBm\n", p);

if info.validPath
    fprintf("Path loss     = %.3f dB\n", info.pathLossDb);
    fprintf("Tx gain       = %.3f dB\n", info.txGainDb);
    fprintf("Rx gain       = %.3f dB\n", info.rxGainDb);
    fprintf("AoD           = [%.3f %.3f] deg\n", info.aodDeg);
    fprintf("AoA           = [%.3f %.3f] deg\n", info.aoaDeg);
else
    fprintf("No valid propagation path found.\n");
end

fprintf("\nRole 1 output is ready for Role 2:\n");
fprintf("  received power -> SNIR -> capacity\n");

fprintf("\nNote: the paper/project target of 61.04 Gbps is\n");
fprintf("a full-system capacity result, not a Role-1-only result.\n");
