# Week 2 — Role 1: Scenario and Channel Physics

This package is the Week-2 Role 1 handoff based on the team's uploaded Week-1 Role 1 files and group plan.

## Included deliverables

- `project_config.m` — shared parameters and paper coordinates.
- `build_role1_scenario.m` — baseline 2 Tx / 2 Rx scenario with `S.txSites`, `S.rxSites`, and `S.cfg.servingTx`.
- `build_scenario_3x6.m` — 3 Tx / 6 Rx scenario and serving map `[1 2 3 1 2 3]`.
- `getSignalPower.m` — strongest (minimum path-loss) ray, antenna directivity, and link-budget received power.
- `steering_weights.m` — phased-array steering vector.
- `check_four_links.m` — baseline four-link diagnostic.
- `run_18_link_report.m` — traces all 18 links, prints AoD/AoA/path loss/ray count, and saves CSV/MAT output plus selected-ray PNGs.
- `report_role1_section.md`, `OSM_SETUP.md`.

## Important assumptions

- 28 GHz, 0.5 W transmit power, 8x4 Tx URA, 4x2 Rx URA, half-wavelength spacing.
- Isotropic antenna element for the frozen v1 model, as agreed in the group plan. Do not mix this with a cosine-element or patch-element table.
- SBR ray tracing with at most one reflection; the minimum-path-loss ray is used for each link.
- Fixed steering elevations: Tx = -30 degrees, Rx = 0 degrees.
- `cfg.servingTx = [1 2 3 1 2 3]` for the large case: Tx1 serves Rx1/Rx4, Tx2 serves Rx2/Rx5, Tx3 serves Rx3/Rx6.
- The code stores approximate heading metadata (clockwise from north). The beam-angle search remains the team's existing azimuth grid and is not silently changed to joint azimuth/elevation search.

## Run instructions

1. Extract this folder fully.
2. In MATLAB, set Current Folder to this directory.
3. Confirm `berlin.osm` covers every site. The supplied map may be too narrow: Rx4 is at longitude 13.503600, west of the old documented lower bound 13.5038. If it is outside the map, export a larger OSM box (suggested longitude 13.5030–13.5050, latitude 52.5605–52.5614), replace `berlin.osm`, and notify Role 2 before freezing the table.
4. Run:
   ```matlab
   check_four_links
   ```
5. Run:
   ```matlab
   S = build_scenario_3x6();
   ```
   Visually confirm all nine sites are inside the loaded buildings in Site Viewer.
6. Run:
   ```matlab
   run_18_link_report
   ```
   The script creates `role1_outputs/links_3x6_report.csv`, `.mat`, and ray figures. Inspect `RayType=UNKNOWN` manually; MATLAB ray object metadata differs by release.
7. Commit only the files in the team's `role1_scenario/` folder. Do not overwrite a tagged table version.

## MATLAB requirements

Antenna Toolbox, Phased Array System Toolbox, and the MATLAB ray-tracing/siteviewer functionality available in the installed release.

## Interpretation / limitations

The script has not been executed in MATLAB in this environment. Therefore no path-loss, AoD/AoA, LOS, or map-coverage results are fabricated here; the CSV and figures are generated when the team runs it in MATLAB. If a wanted link has no path, record it as a channel-model limitation before Role 2 builds the large table.
