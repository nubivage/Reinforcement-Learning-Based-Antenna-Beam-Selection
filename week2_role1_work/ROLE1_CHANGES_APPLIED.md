# Week-2 changes applied in this handoff

- Added common scenario fields `S.txSites`, `S.rxSites`, and `S.cfg.servingTx`.
- Added `build_scenario_3x6.m` with all six receiver coordinates and serving rule `[1 2 3 1 2 3]`.
- Standardized the antenna element to `phased.IsotropicAntennaElement` for v1, per the group plan.
- Updated `getSignalPower.m` to handle missing paths and invalid path loss safely, expose diagnostic fields, and avoid printing on every call.
- Added a four-link check and an 18-link report generator.
- Updated report and OSM coverage instructions.

## Important
The uploaded archive did not contain a file literally named `ROLE1_CHANGES.md` or the group's expected-value comparison harness. The changes above implement the relevant decisions stated in the supplied Week-2 plan, but the four-link numerical tolerance must still be checked against the actual Role-2 table in MATLAB.
