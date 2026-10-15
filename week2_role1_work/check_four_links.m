% CHECK_FOUR_LINKS
% Compare the saved reference table, a freshly generated table,
% and runtime channel calculations for all four Tx-Rx links.
%
% IMPORTANT:
% This script does NOT overwrite linkTable.mat.

clear; clc;

%% 1. Load the saved reference table

if ~isfile('linkTable.mat')
    error('check_four_links:MissingTable', ...
        'linkTable.mat was not found in the current folder.');
end

load('linkTable.mat', 'T');
Tref = T;
clear T;

%% 2. Build the scenario and generate a fresh table

fprintf('Building the Role-1 scenario...\n');
S = build_role1_scenario();
cfg = S.cfg;

fprintf('Generating a fresh link table. This may take some time...\n');
Tfresh = Buildlinktable(S);

fprintf('Fresh table generated successfully.\n\n');

%% 3. Find the zero-degree steering entries

[~, a0] = min(abs(Tref.txAz));
[~, b0] = min(abs(Tref.rxAz));

fprintf('REFERENCE TABLE: linkTable.mat\n');
fprintf('Tx zero-angle index = %d (%.1f deg)\n', ...
    a0, Tref.txAz(a0));
fprintf('Rx zero-angle index = %d (%.1f deg)\n', ...
    b0, Tref.rxAz(b0));

fprintf('Reference Tx gain array size: ');
disp(size(Tref.txGainDb));

fprintf('Reference Rx gain array size: ');
disp(size(Tref.rxGainDb));

fprintf('Reference Tx headings (deg): ');
disp(Tref.txHeading);

fprintf('Reference Rx headings (deg): ');
disp(Tref.rxHeading);

fprintf('\n');

%% 4. Compare the saved table with the freshly generated table

fprintf('SAVED TABLE vs FRESH TABLE AT ZERO-DEGREE STEERING\n');
fprintf('%s\n', repmat('-', 1, 88));

fprintf(['Link       SavedTx   FreshTx   TxDiff', ...
         '     SavedRx   FreshRx   RxDiff\n']);

pairs = [1 1; 1 2; 2 1; 2 2];

for k = 1:size(pairs, 1)
    i = pairs(k, 1);
    j = pairs(k, 2);

    savedTx = Tref.txGainDb(i, j, a0);
    freshTx = Tfresh.txGainDb(i, j, a0);

    savedRx = Tref.rxGainDb(i, j, b0);
    freshRx = Tfresh.rxGainDb(i, j, b0);

    fprintf(['Tx%d-Rx%d   %8.3f  %8.3f  %8.3f', ...
             '   %8.3f  %8.3f  %8.3f\n'], ...
        i, j, savedTx, freshTx, freshTx-savedTx, ...
        savedRx, freshRx, freshRx-savedRx);
end

fprintf('\n');

%% 5. Compare runtime gains against both tables

fprintf('RUNTIME CHANNEL CALCULATION vs REFERENCE TABLE\n');
fprintf('%s\n', repmat('-', 1, 88));

fprintf(['Link       Valid   Rays   PL(dB)   RuntimeTx', ...
         '   TableTx   FreshTx   RuntimeRx   TableRx   FreshRx\n']);

for k = 1:size(pairs, 1)
    i = pairs(k, 1);
    j = pairs(k, 2);

    % Calculate runtime received power and gains using the saved headings.
    [p, info] = getSignalPower( ...
        S.txSites{i}, S.rxSites{j}, ...
        Tref.txAz(a0), cfg.txElevation, ...
        Tref.rxAz(b0), cfg.rxElevation, ...
        S.txArray, S.rxArray, S.rayModel, ...
        cfg.f, cfg.txPowerDbm, ...
        Tref.txHeading(i), Tref.rxHeading(j));

    % Gains stored in the saved table.
    savedTx = Tref.txGainDb(i, j, a0);
    savedRx = Tref.rxGainDb(i, j, b0);

    % Gains stored in the freshly generated table.
    freshTx = Tfresh.txGainDb(i, j, a0);
    freshRx = Tfresh.rxGainDb(i, j, b0);

    fprintf(['Tx%d-Rx%d      %d    %4d   %7.3f', ...
             '   %9.3f %9.3f %9.3f', ...
             '   %10.3f %9.3f %9.3f\n'], ...
        i, j, info.validPath, info.numRays, info.pathLossDb, ...
        info.txGainDb, savedTx, freshTx, ...
        info.rxGainDb, savedRx, freshRx);

    % Compare the runtime ray angles with the reference table.
    fprintf('    Runtime AoD = [%8.3f %8.3f]\n', ...
        info.aodDeg(1), info.aodDeg(2));

    fprintf('    Saved   AoD = [%8.3f %8.3f]\n', ...
        Tref.aod(i,j,1), Tref.aod(i,j,2));

    fprintf('    Runtime AoA = [%8.3f %8.3f]\n', ...
        info.aoaDeg(1), info.aoaDeg(2));

    fprintf('    Saved   AoA = [%8.3f %8.3f]\n', ...
        Tref.aoa(i,j,1), Tref.aoa(i,j,2));

    fprintf('    Runtime minus saved: Tx=%+.3f dB, Rx=%+.3f dB\n', ...
        info.txGainDb-savedTx, info.rxGainDb-savedRx);

    fprintf('\n');
end

%% 6. Final guidance

fprintf('INTERPRETATION\n');
fprintf(['1. If the fresh table matches the saved table, ', ...
         'the saved table is reproducible with the current code.\n']);

fprintf(['2. If the fresh table differs from the saved table, ', ...
         'investigate differences in code, configuration, ', ...
         'or ray-tracing results.\n']);

fprintf(['3. If runtime gains differ from the fresh table, ', ...
         'investigate the runtime gain calculation and ', ...
         'steering-angle conventions.\n']);

fprintf(['4. linkTable.mat has NOT been overwritten. ', ...
         'Do not replace it until the discrepancy is understood.\n']);
