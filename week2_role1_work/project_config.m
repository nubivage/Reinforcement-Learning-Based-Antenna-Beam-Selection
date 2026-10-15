function cfg = project_config()
%PROJECT_CONFIG Shared Role-1 geometry and channel configuration.
% Coordinates are [latitude, longitude, height_m]; angles are degrees.
cfg.f = 28e9;
cfg.c = physconst('LightSpeed');
cfg.lambda = cfg.c/cfg.f;
cfg.txPowerW = 0.5;
cfg.txPowerDbm = 10*log10(1000*cfg.txPowerW);
cfg.txRows = 8; cfg.txCols = 4;
cfg.rxRows = 4; cfg.rxCols = 2;
cfg.elementSpacing = [cfg.lambda/2 cfg.lambda/2];
cfg.tx1 = [52.561075, 13.503874, 14];
cfg.tx2 = [52.560802, 13.504149, 12];
cfg.rx1 = [52.560834, 13.504560, 1];
cfg.rx2 = [52.561001, 13.503810, 1];
cfg.txAzimuths = -60:5:60;
cfg.rxAzimuths = -60:10:60;
cfg.txElevation = -30;
cfg.rxElevation = 0;
cfg.osmFile = "berlin.osm";
cfg.maxReflections = 1;
cfg.noiseTemperatureK = 300;
% Reference configuration from the group's Week-1 ground-truth notes.
cfg.referenceTx1Az = 30; cfg.referenceTx2Az = 50;
cfg.referenceRx1Az = -30; cfg.referenceRx2Az = 20;
cfg.referenceCapacityGbps = 61.04;
% Versioning/assumption metadata.
cfg.channelModelVersion = "week2_role1_v1";
cfg.antennaElementModel = "IsotropicAntennaElement";
end
