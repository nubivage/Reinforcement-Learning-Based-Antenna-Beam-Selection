# Role 1 — Scenario and Channel Physics (Week 2)

## 1. Purpose and interface
Role 1 supplies the physical urban scenario and angle-dependent link power to Role 2. The shared MATLAB interface is `S.cfg`, `S.txSites`, `S.rxSites`, `S.txArray`, `S.rxArray`, and `S.rayModel`. The 2x2 scenario uses `S.cfg.servingTx = [1 2]`; the 3x6 scenario uses `[1 2 3 1 2 3]`.

Role 1 computes propagation paths, path loss, departure/arrival angles, antenna gains, and received power. SINR, Shannon capacity, exhaustive search, and reinforcement learning belong to Roles 2 and 3.

## 2. Geometry
Carrier frequency is 28 GHz. Transmitter coordinates use the paper's listed heights; receiver height is 1 m.

| Site | Latitude | Longitude | Height |
|---|---:|---:|---:|
| Tx1 | 52.561075 | 13.503874 | 14 m |
| Tx2 | 52.560802 | 13.504149 | 12 m |
| Tx3 | 52.560865 | 13.504520 | 14 m |
| Rx1 | 52.560834 | 13.504560 | 1 m |
| Rx2 | 52.561001 | 13.503810 | 1 m |
| Rx3 | 52.560785 | 13.504211 | 1 m |
| Rx4 | 52.560980 | 13.503600 | 1 m |
| Rx5 | 52.560950 | 13.504023 | 1 m |
| Rx6 | 52.560878 | 13.504284 | 1 m |

Serving assignment: Tx1 serves Rx1 and Rx4; Tx2 serves Rx2 and Rx5; Tx3 serves Rx3 and Rx6. Every other Tx-to-Rx link is a potential interferer in the capacity model.

## 3. Arrays and beam assumptions
Each transmitter uses an 8x4 uniform rectangular array; each receiver uses a 4x2 array. Element spacing is half a wavelength. The v1 element is `phased.IsotropicAntennaElement`, matching the group's shared-table decision. Transmit steering elevation is fixed at -30 degrees and receiver steering elevation at 0 degrees. Beam azimuth grids remain Tx -60:5:60 degrees and Rx -60:10:60 degrees.

Approximate array headings are computed from site geometry and stored as metadata. Tx headings use the circular mean of bearings to the two served receivers; each Rx heading points toward its serving Tx. The table builder must use the same local-angle convention before these headings can be interpreted as an actual array rotation.

## 4. Propagation and received power
The urban channel uses shooting-and-bouncing ray tracing (SBR), with at most one reflection. For each Tx-Rx pair, the implementation selects the valid ray with minimum path loss. Antenna directivity is evaluated at that ray's AoD and the reverse source direction derived from AoA.

`Pr[dBm] = Pt[dBm] + Gt[dBi] - PL[dB] + Gr[dBi]`

If no valid ray exists, `getSignalPower` returns `-Inf` and `info.validPath=false`; the large-scenario report records the missing path. Ray classification is `UNKNOWN` when the MATLAB release does not expose reliable interaction metadata. Do not infer LOS from angle relationships alone.

## 5. Week-2 validation procedure
1. Run `check_four_links` and compare its output against Role 2's frozen 2x2 table. Both calculations must use the same OSM file, isotropic element, angle convention, ray-selection rule, and configuration.
2. Run `S = build_scenario_3x6()` and visually inspect the nine site markers in Site Viewer.
3. Run `run_18_link_report`. It traces all 18 links and saves `role1_outputs/links_3x6_report.csv`, a MAT file, and selected-ray plots.
4. Review the six wanted links (Tx1-Rx1, Tx1-Rx4, Tx2-Rx2, Tx2-Rx5, Tx3-Rx3, Tx3-Rx6). Escalate any missing wanted link.
5. Compare the AoD azimuths of Tx1-Rx1 and Tx1-Rx4. A large separation indicates one fixed Tx1 beam may not serve both receivers well; report per-link results and record the limitation.

## 6. Map coverage decision (D0/D1)
The Week-1 map notes give longitude coverage beginning at 13.5038, but Rx4 is at longitude 13.503600. Thus the supplied OSM file must be checked in Site Viewer and may not cover Rx4. If any site is outside, re-export a larger map (suggested longitude 13.5030–13.5050 and latitude 52.5605–52.5614). Inform Role 2 before rebuilding/finalizing `linkTable_2x2_v1.mat`, because extra buildings can introduce reflections and change path losses.

## 7. Results — populate after MATLAB run
Do not report invented path losses or ray counts. Attach the generated `links_3x6_report.csv` and summarize:
- Links with no path and whether each is wanted.
- Path loss and ray count for each of the 18 links.
- AoD/AoA azimuth and elevation for the selected minimum-loss ray.
- LOS versus reflected/other ray classification, based on MATLAB ray interaction metadata.
- Tx1's AoD separation toward Rx1 and Rx4.
- Screenshot of Site Viewer with all nine sites, plus selected-ray figures.

## 8. Limitations
- Fixed Tx/Rx steering elevations can reduce gains when geometric elevation differs from the selected steering elevation.
- Tx1's two served receivers may have widely separated bearings, making one shared beam a compromise.
- The minimum-path-loss-ray model does not coherently combine multipath components.
- Absolute capacity depends on Role 2's capacity formula and should primarily be compared to the paper through ratios and method ranking, as agreed in the group plan.
- A map update or antenna-element change invalidates the frozen channel-table version and requires a new versioned table plus reruns.

## 9. Reproducibility record
Record MATLAB release, toolbox versions, OSM export bounds/date, `cfg.channelModelVersion`, element model, reflection count, angle grids, and exact table version used by Role 2. Never overwrite a frozen v1 table.
