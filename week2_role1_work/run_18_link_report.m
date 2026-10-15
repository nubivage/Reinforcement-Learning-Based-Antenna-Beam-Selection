%RUN_18_LINK_REPORT Trace all 18 links and save CSV + diagnostic figures.
clear; clc;
S = build_scenario_3x6();
outDir = fullfile(pwd,'role1_outputs');
if ~exist(outDir,'dir'), mkdir(outDir); end
rows = cell(18,10); n=0;
fprintf('Link       Rays  PL(dB)   AoD az/el       AoA az/el       Type       Served?\n');
for i=1:numel(S.txSites)
    for j=1:numel(S.rxSites)
        n=n+1;
        rays = raytrace(S.txSites{i},S.rxSites{j},S.rayModel);
        if isempty(rays) || isempty(rays{1})
            rows(n,:) = {i,j,0,NaN,NaN,NaN,NaN,NaN,'NO_PATH',i==S.cfg.servingTx(j)};
            fprintf('Tx%d-Rx%d   0     NO PATH                                      %d\n',i,j,i==S.cfg.servingTx(j));
            continue
        end
        p = rays{1};

losCount = 0;
for m = 1:numel(p)
    if isprop(p(m), 'LineOfSight') && p(m).LineOfSight
        losCount = losCount + 1;
    end
end
        pls=[p.PathLoss]; good=isfinite(pls);
        if ~any(good)
            rows(n,:)={i,j,numel(p),NaN,NaN,NaN,NaN,NaN,'INVALID_PATHLOSS',i==S.cfg.servingTx(j)};
            continue
        end
        ids=find(good); [~,kk]=min(pls(good)); r=p(ids(kk));
        aod=double(r.AngleOfDeparture(:)); aoa=double(r.AngleOfArrival(:));
        

typ = "UNKNOWN";

if isprop(r, 'LineOfSight') && r.LineOfSight
    typ = "LOS";
elseif isprop(r, 'NumInteractions') && r.NumInteractions > 0
    typ = "REFLECTION/OTHER";
end


        wanted = i==S.cfg.servingTx(j);
        rows(n,:)={i,j,numel(p),double(r.PathLoss),aod(1),aod(2),aoa(1),aoa(2),char(typ),wanted};
        fprintf('Tx%d-Rx%d  %3d  %7.2f  [%7.2f %6.2f]  [%7.2f %6.2f]  %-14s %d\n', ...
            i,j,numel(p),r.PathLoss,aod(1),aod(2),aoa(1),aoa(2),typ,wanted);
        % Save ray figures for representative wanted and cross links.
        if wanted || (i==1 && j==4)
            fig=figure('Visible','off');
            try
                plot(r);
                title(sprintf('Tx%d to Rx%d selected ray (min path loss)',i,j));
                saveas(fig,fullfile(outDir,sprintf('ray_Tx%d_Rx%d.png',i,j)));
            catch ME
                warning('Could not plot ray Tx%d-Rx%d: %s',i,j,ME.message);
            end
            close(fig);
        end
    end
end
T=cell2table(rows,'VariableNames',{'Tx','Rx','NumRays','PathLoss_dB', ...
    'AoD_Azimuth_deg','AoD_Elevation_deg','AoA_Azimuth_deg','AoA_Elevation_deg','RayType','WantedLink'});
writetable(T,fullfile(outDir,'links_3x6_report.csv'));
save(fullfile(outDir,'links_3x6_report.mat'),'T','S');
fprintf('\nSaved %s\n',fullfile(outDir,'links_3x6_report.csv'));
fprintf('Wanted links missing: ');
wantedCol = T.WantedLink;
rayTypeCol = string(T.RayType);
missing = wantedCol & (rayTypeCol == "NO_PATH");
if any(missing)
    for q=find(missing)', fprintf('Tx%d-Rx%d ',T.Tx{q},T.Rx{q}); end
    fprintf('\n');
else
    fprintf('none detected by this run (check CSV for invalid/unknown rows).\n');
end
fprintf(['Map coverage is a visual gate: inspect all 9 markers in Site Viewer. ', ...
    'Rx4 longitude is 13.503600, west of the original OSM_SETUP range.\n']);
