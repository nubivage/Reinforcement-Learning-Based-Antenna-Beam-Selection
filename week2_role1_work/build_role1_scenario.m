function S = build_role1_scenario()
%BUILD_ROLE1_SCENARIO Construct the baseline 2 Tx / 2 Rx scenario.
% Returns the stable interface shared with Role 2/Role 3.
cfg = project_config();
if ~isfile(cfg.osmFile)
    error('build_role1_scenario:MissingOSM', ...
        'Cannot find %s. Put the exported Berlin OSM map in %s.',cfg.osmFile,pwd);
end
viewer = siteviewer(Buildings=cfg.osmFile);
tx1 = txsite(Latitude=cfg.tx1(1),Longitude=cfg.tx1(2), ...
    AntennaHeight=cfg.tx1(3),TransmitterFrequency=cfg.f);
tx2 = txsite(Latitude=cfg.tx2(1),Longitude=cfg.tx2(2), ...
    AntennaHeight=cfg.tx2(3),TransmitterFrequency=cfg.f);
rx1 = rxsite(Latitude=cfg.rx1(1),Longitude=cfg.rx1(2),AntennaHeight=cfg.rx1(3));
rx2 = rxsite(Latitude=cfg.rx2(1),Longitude=cfg.rx2(2),AntennaHeight=cfg.rx2(3));
show(tx1); show(tx2); show(rx1); show(rx2);

% Group decision: isotropic element for the frozen v1 reference pipeline.
elem = phased.IsotropicAntennaElement;
txArray = phased.URA(Size=[cfg.txRows cfg.txCols], ...
    ElementSpacing=cfg.elementSpacing,Element=elem);
rxArray = phased.URA(Size=[cfg.rxRows cfg.rxCols], ...
    ElementSpacing=cfg.elementSpacing,Element=elem);
rayModel = propagationModel("raytracing",Method="sbr", ...
    MaxNumReflections=cfg.maxReflections);

S = struct('cfg',cfg,'viewer',viewer,'tx1',tx1,'tx2',tx2, ...
    'rx1',rx1,'rx2',rx2,'txArray',txArray,'rxArray',rxArray, ...
    'rayModel',rayModel);
% Stable site lists and serving map are required by the N-Tx builder.
S.txSites = {tx1,tx2};
S.rxSites = {rx1,rx2};
S.cfg.servingTx = [1 2]; % Rx k is served by Tx k in the 2x2 case.
S.cfg.txHeadingsDeg = [bearingDeg(cfg.tx1,cfg.rx1), ...
                       bearingDeg(cfg.tx2,cfg.rx2)];
S.cfg.rxHeadingsDeg = [bearingDeg(cfg.rx1,cfg.tx1), ...
                       bearingDeg(cfg.rx2,cfg.tx2)];
end

function az = bearingDeg(a,b)
% Approximate local tangent-plane bearing, clockwise from north.
dLat = deg2rad(b(1)-a(1));
dLon = deg2rad(b(2)-a(2))*cos(deg2rad((a(1)+b(1))/2));
az = mod(atan2d(dLon,dLat),360);
end
