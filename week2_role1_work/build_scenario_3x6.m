function S = build_scenario_3x6()
%BUILD_SCENARIO_3X6 Construct the paper's 3 Tx / 6 Rx scenario.
% Rx1..Rx6 are served by Tx1,Tx2,Tx3,Tx1,Tx2,Tx3 respectively.
S2 = build_role1_scenario();
S = S2;
cfg = S2.cfg;
cfg.tx3 = [52.560865,13.504520,14];
cfg.rx3 = [52.560785,13.504211,1];
cfg.rx4 = [52.560980,13.503600,1];
cfg.rx5 = [52.560950,13.504023,1];
cfg.rx6 = [52.560878,13.504284,1];
cfg.servingTx = [1 2 3 1 2 3];
tx3 = txsite(Latitude=cfg.tx3(1),Longitude=cfg.tx3(2), ...
    AntennaHeight=cfg.tx3(3),TransmitterFrequency=cfg.f);
rx3 = rxsite(Latitude=cfg.rx3(1),Longitude=cfg.rx3(2),AntennaHeight=cfg.rx3(3));
rx4 = rxsite(Latitude=cfg.rx4(1),Longitude=cfg.rx4(2),AntennaHeight=cfg.rx4(3));
rx5 = rxsite(Latitude=cfg.rx5(1),Longitude=cfg.rx5(2),AntennaHeight=cfg.rx5(3));
rx6 = rxsite(Latitude=cfg.rx6(1),Longitude=cfg.rx6(2),AntennaHeight=cfg.rx6(3));
show(tx3); show(rx3); show(rx4); show(rx5); show(rx6);
S.cfg = cfg;
S.tx3 = tx3;
S.rx3 = rx3; S.rx4 = rx4; S.rx5 = rx5; S.rx6 = rx6;
S.txSites = {S.tx1,S.tx2,tx3};
S.rxSites = {S.rx1,S.rx2,rx3,rx4,rx5,rx6};
% Each array faces the circular-mean direction of its served partner(s).
% Store headings as metadata; beam-angle grid is relative to this heading.
txHeadings = zeros(1,3);
for k=1:3
    rxs = find(cfg.servingTx==k);
    bearings = zeros(1,numel(rxs));
    for q=1:numel(rxs)
        bearings(q)=bearingDeg(siteCoordinates(S.txSites{k}),siteCoordinates(S.rxSites{rxs(q)}));
    end
    txHeadings(k)=circularMeanDeg(bearings);
end
rxHeadings = zeros(1,6);
for j=1:6
    rxHeadings(j)=bearingDeg(siteCoordinates(S.rxSites{j}), ...
        siteCoordinates(S.txSites{cfg.servingTx(j)}));
end
S.cfg.txHeadingsDeg = txHeadings;
S.cfg.rxHeadingsDeg = rxHeadings;
end

function c = siteCoordinates(site)
% Retrieve lat/lon/height from a site object.
c = [site.Latitude,site.Longitude,site.AntennaHeight];
end
function az = bearingDeg(a,b)
dLat=deg2rad(b(1)-a(1));
dLon=deg2rad(b(2)-a(2))*cos(deg2rad((a(1)+b(1))/2));
az=mod(atan2d(dLon,dLat),360);
end
function m = circularMeanDeg(a)
m=mod(atan2d(mean(sind(a)),mean(cosd(a))),360);
end
