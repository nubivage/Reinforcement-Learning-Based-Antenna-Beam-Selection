# Role 1 — Geometry and Channel Model

## 1. Objective

The objective of Role 1 is to construct the physical urban wireless environment and produce a beam-angle-dependent received-power model that can be used by the capacity and reinforcement-learning modules.

## 2. Simulation geometry

The simulation represents an urban environment in Northeast Berlin using OpenStreetMap building geometry. Two transmitter sites and two receiver sites are defined using the coordinates specified by the reference paper.

## 3. Antenna configuration

The carrier frequency is 28 GHz. Each transmitter uses an 8 x 4 uniform rectangular array and each receiver uses a 4 x 2 uniform rectangular array. The inter-element spacing is one half wavelength.

The transmitters are initially tilted 30 degrees downward. Beam steering is implemented electronically using a steering vector, allowing the azimuth and elevation of the main beam to be changed without physically moving the antenna.

## 4. Propagation model

The channel is modeled using shooting and bouncing ray tracing with a maximum of one reflection. For each Tx-Rx link, the ray-tracing engine provides propagation information such as path loss, angle of departure, angle of arrival, phase shift, and propagation delay where available.

## 5. Beamforming gain

The steering vector generates complex weights for the desired beam direction. The antenna pattern is then evaluated at the actual direction of the selected propagation path. This gives a direction-dependent Tx and Rx beamforming gain.

## 6. Received power

For the selected propagation path, the received signal power is calculated using:

Pr[dBm] = Pt[dBm] + Gtx[dB] - PL[dB] + Grx[dB]

where Pt is the transmitter power, Gtx and Grx are the beamforming gains, and PL is the ray-traced path loss.

## 7. Output

The central function `getSignalPower()` returns both the received power and diagnostic channel information. The function can therefore be called repeatedly by the capacity module for different beam-angle combinations.

## 8. Validation

The Role-1 validation checks that:
- the ray-tracing model produces a valid path,
- path loss and propagation directions are extracted,
- Tx/Rx gains are calculated,
- received power changes as beam angles are changed,
- no-path conditions are handled safely.

## 9. Limitation and next refinement

The reference paper describes rectangular patch antenna elements and reports a maximum bore-side antenna gain of 15.95 dBi. The first implementation uses MATLAB's cosine antenna element to establish a stable end-to-end pipeline. The patch-element model and radiation-pattern calibration can be introduced after the pipeline is verified.

## 10. Interface to the rest of the project

Role 2 uses `getSignalPower()` to obtain desired and interfering received powers for the four Tx-Rx links. These values are then used to calculate SNIR and channel capacity. Role 3 can use the resulting capacity as the reinforcement-learning reward.
