close all
clear all

addpath('../expfig/')
addpath(genpath('data'))

%% get the data
% Spergel Landsat 8
for i = 1:4
    fn = sprintf('L8_depthprofile_%d.txt',i);
    dat = readmatrix(fn);
    spergel.depth{i} = dat(:,2) / 1000; % make meters
    spergel.lat{i} = dat(:,3);
    spergel.lon{i} = dat(:,4);
end

% Fair ICESat-2
for i = 1:4
    fn = sprintf('amery_pond_%d.txt',i);
    dat = readmatrix(fn);
    fair.depth{i} = dat(:,3);
    fair.lat{i} = dat(:,1);
    fair.lon{i} = dat(:,2);
end

% Magruder
for i = 1:4
    fn = sprintf('Antarctic_MeltPonds_%d.csv',i);
    dat = readmatrix(fn);
    magruder.depth{i} = dat(:,6);
    magruder.lat{i} = dat(:,1);
end

% had to interpolate sentinel-2 
load popedata

% photon data
fn3 = 'processed_ATL03_20190102184312_00810210_001_01.h5';
ph = 'heights/h_ph';
plat = 'heights/lat_ph';
pconf = 'heights/signal_conf_ph';
sh = 'land_ice_segments/h_li';
slat = 'land_ice_segments/latitude';

beam = '/gt2l/';
lat2l = h5read(fn3,[beam plat]);
h2l = h5read(fn3,[beam ph]);
conf2l = h5read(fn3,[beam pconf]);
conf2l = conf2l(4,:); %this is the one for land ice

% pond limits
l{1} = [-73.013 -72.987];
l{2} = [-72.899 -72.867];
l{3} = [-71.878 -71.866];
l{4} = [-71.65 -71.632];

% plot
fig = figure(1);
set(fig,'units','normalized','outerposition',[0 0 1 1])
cols = lines(4);

for pond = 1:4

    lim2l = lat2l > l{pond}(1) & lat2l < l{pond}(2);
    photlat2l = lat2l(lim2l);
    photh2l = h2l(lim2l);
    photconf = conf2l(lim2l);
    edg = linspace(l{pond}(1),l{pond}(2),150);
    mid = edg(1:end-1) + (edg(2) - edg(1)) / 2;
    surf = nan(length(mid),1);
    for i = 1:length(mid)
        in = photlat2l > edg(i) & photlat2l < edg(i+1);
        n = sum(in);
        sel = sort(photh2l(in));
        surf(i) = sel(ceil(0.8*n)); % interpret 80th percentile as surface
    end
    surfint = interp1(mid,surf,photlat2l);
    depth = surfint - photh2l;

    subplot(2,2,pond)
    hold on
    p(5) = scatter(photlat2l,depth,2,'MarkerFaceColor','k','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0);
    p(1) = plot(magruder.lat{pond},magruder.depth{pond},'linewidth',2,'color',cols(1,:));
    p(2) = plot(fair.lat{pond},fair.depth{pond},'linewidth',2,'color',cols(2,:));
    p(3) = plot(spergel.lat{pond},spergel.depth{pond},'linewidth',2,'color',cols(3,:));
    p(4) = plot(latspope,depthpope/1000,'linewidth',2,'color',cols(4,:));
    set(gca, 'YDir','reverse')
    
    xlim(l{pond})
    ylim([-2 8])
    title(sprintf('pond %d', pond))
    grid on
    xlabel('lat')
    ylabel('depth [m]')
end

hL = legend(p,{'ICESat-2 (Magruder)','ICESat-2 (Fair/Flanner)','Landsat8 Jan 01 (Spergel/Kingslake)','Sentinel2 Jan 02 (Moussavi/Pope)','ATL03 gt2l Jan 02 (normalized to surface)'});
newPosition = [0.35 0.48 0.3 0.04];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits, 'NumColumns', 5);

% export_fig fig/pondDepthComparison.png -m2 -transparent