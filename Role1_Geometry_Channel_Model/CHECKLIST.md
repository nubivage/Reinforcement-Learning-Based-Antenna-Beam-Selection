# Role 1 completion checklist

## A. Geometry

[ ] Berlin OSM file loaded
[ ] Siteviewer opens
[ ] Tx1 visible
[ ] Tx2 visible
[ ] Rx1 visible
[ ] Rx2 visible

## B. Physical parameters

[ ] 28 GHz
[ ] 0.5 W Tx power
[ ] 400 MHz bandwidth recorded for integration
[ ] Tx heights 14 m and 12 m
[ ] Rx heights 1 m and 1 m

## C. Arrays

[ ] Tx = 8 x 4 URA
[ ] Rx = 4 x 2 URA
[ ] spacing = lambda/2
[ ] steering vector works
[ ] changing steering angle changes pattern

## D. Channel model

[ ] SBR ray tracing
[ ] maximum 1 reflection
[ ] at least one valid test path
[ ] path loss extracted
[ ] AoD extracted
[ ] AoA extracted

## E. Received power

[ ] Tx gain extracted
[ ] Rx gain extracted
[ ] getSignalPower returns dBm
[ ] no-path case returns -Inf rather than crashing
[ ] received power changes with beam angles

## F. Handoff

[ ] Role 2 can call getSignalPower
[ ] four Tx-Rx links can be evaluated
[ ] Role 2 receives path loss and beam gains
[ ] Role 3 can eventually use Role 2's capacity/reward

## G. Final-fidelity upgrade

[ ] Replace cosine element with rectangular patch if needed
[ ] Calibrate radiation pattern/gain
[ ] Verify coordinate/map fidelity
[ ] Compare integrated capacity with 61.04 Gbps target
