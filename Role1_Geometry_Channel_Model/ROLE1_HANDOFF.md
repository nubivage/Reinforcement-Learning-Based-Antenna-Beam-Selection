# Role 1 -> Role 2 / Role 3 Handoff

## Main function

```matlab
[powerDbm, info] = getSignalPower( ...
    txSite, rxSite, ...
    txAz, txEl, rxAz, rxEl, ...
    txArray, rxArray, rayModel, ...
    f, txPowerDbm);
```

## Meaning of `powerDbm`

This is the physical received signal power for ONE Tx-Rx link after:

1. urban ray tracing
2. selecting the strongest/lowest-path-loss ray
3. Tx beamforming gain at that ray's AoD
4. Rx beamforming gain at that ray's AoA
5. applying the link budget

```text
Pr[dBm] = Pt[dBm] + Gtx[dB] - PathLoss[dB] + Grx[dB]
```

## Meaning of `info`

`info.pathLossDb`
: selected propagation-path loss.

`info.txGainDb`
: Tx array gain in the actual ray departure direction.

`info.rxGainDb`
: Rx array gain in the actual ray arrival direction.

`info.aodDeg`
: [azimuth elevation] of departure.

`info.aoaDeg`
: [azimuth elevation] of arrival.

`info.phaseShiftDeg`
: phase shift if available in the MATLAB ray object.

`info.propagationDelaySec`
: propagation delay if available.

## For the 2-Tx / 2-Rx scenario

Role 2 should call Role 1 for all four links:

```text
Tx1 -> Rx1
Tx1 -> Rx2
Tx2 -> Rx1
Tx2 -> Rx2
```

For a chosen angle tuple:

```text
[Tx1_angle, Tx2_angle, Rx1_angle, Rx2_angle]
```

Role 2 can identify:
- desired signal power
- interfering signal power
- total interference
- noise power
- SNIR
- channel capacity

Do NOT assume the other transmitter's signal is useful signal at the receiver. It becomes interference for the corresponding receiver.

## Angle grids from the project plan

Tx:
```matlab
txAngles = -60:5:60;
```

Rx:
```matlab
rxAngles = -60:10:60;
```

For the small 2-Tx/2-Rx scenario:

```text
25 x 25 x 13 x 13 = 105625 combinations
```

Do not run the full grid until the small test case works.

## Reference configuration

The project plan gives:

```text
Tx1 = 30°
Tx2 = 50°
Rx1 = -30°
Rx2 = 20°
```

with a reported target total capacity of:

```text
61.04 Gbps
```

That target is for the complete integrated calculation.

## Role 1 does NOT calculate

- SNIR
- Shannon capacity
- total network capacity
- exhaustive beam search
- Q-learning
- Double Q-learning
- SARSA
- Expected SARSA
- Monte Carlo learning

Those belong to the other project roles.

## Recommended integration test

Before connecting RL:

1. Use only 2 or 3 angle choices per node.
2. Evaluate the four links.
3. Calculate one SNIR.
4. Calculate one capacity.
5. Confirm that the complete pipeline executes.
6. Only then expand to the full 25/13 angle grids.
