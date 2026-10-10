# Role 1 — Geometry & Channel Model

This package implements the first team's assigned component for the paper:

"Reinforcement Learning Based Antenna Beam Selection for Wireless Communications in Urban Environments"

## What Role 1 must produce

Given:
- one transmitter site
- one receiver site
- Tx beam azimuth/elevation
- Rx beam azimuth/elevation

return:
- received signal power in dBm
- path loss
- Tx beamforming gain toward the ray's departure direction
- Rx beamforming gain toward the ray's arrival direction
- AoD/AoA and other useful ray information

The rest of the project can then use this output to calculate SNIR, channel capacity, exhaustive-search rewards, and RL rewards.

## Paper parameters implemented

- Carrier frequency: 28 GHz
- Bandwidth: 400 MHz
- Tx power: 0.5 W per transmitter
- Tx array: 8 x 4 URA
- Rx array: 4 x 2 URA
- Element spacing: lambda/2
- Tx initial elevation tilt: -30 degrees
- Tx azimuth candidates: -60:5:60 (25 values)
- Rx azimuth candidates: -60:10:60 (13 values)
- Ray tracing: SBR, maximum 1 reflection
- Noise temperature: 300 K
- Tx1: [52.561075, 13.503874, 14]
- Tx2: [52.560802, 13.504149, 12]
- Rx1: [52.560834, 13.504560, 1]
- Rx2: [52.561001, 13.503810, 1]

The paper states that its final antenna element is a rectangular patch and that maximum bore-side antenna gain reaches 15.95 dBi. This Week-1 implementation uses MATLAB's CosineAntennaElement first so the complete pipeline is easier to debug. A patch element can be introduced later.

## Required MATLAB capabilities

The implementation uses:
- Antenna Toolbox
- Phased Array System Toolbox
- Communications Toolbox / MATLAB functionality needed by ray tracing

Check your MATLAB installation with:

    ver

## Required map file

Place `berlin.osm` in this same folder.

The OSM file should cover the coordinates around:
- latitude 52.5608–52.5611
- longitude 13.5038–13.5046

Do not substitute a random Berlin map if you are trying to reproduce the paper's geometry.

## First run

Open MATLAB and set the Current Folder to this directory.

Run:

    main_role1

This will:
1. load the project configuration
2. build the Berlin site model
3. create Tx/Rx sites
4. create 8x4 and 4x2 arrays
5. create the SBR ray-tracing model
6. visualize one steered antenna pattern
7. run a few channel-power tests
8. demonstrate the Role-2 handoff

## Core function

The main interface is:

    [powerDbm, info] = getSignalPower( ...
        txSite, rxSite, ...
        txAz, txEl, rxAz, rxEl, ...
        txArray, rxArray, rayModel, f, txPowerDbm);

Example:

    [p, info] = getSignalPower( ...
        tx1, rx1, ...
        30, -30, -30, 0, ...
        txArray, rxArray, rayModel, ...
        cfg.f, cfg.txPowerDbm);

## Important interpretation

The result from `getSignalPower` is NOT the final project capacity.

Role 1:
    geometry -> ray tracing -> beam gains -> received signal power

Role 2:
    received signal powers -> SNIR -> capacity

Role 3:
    capacity -> reward -> RL beam selection

The paper's 61.04 Gbps result belongs to the full integrated system, not to Role 1 alone.

## Validation criterion

At minimum, confirm:
1. `raytrace` returns at least one valid path for at least one test link.
2. Path loss is finite for a valid path.
3. Received power changes when beam angles change.
4. Steering approximately toward a useful propagation direction generally gives a higher gain than steering far away.
5. The function handles no-path cases without crashing.

Exact reproduction of 61.04 Gbps should be treated as an integration/calibration target, not a Role-1 unit test.
