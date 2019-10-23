close all
clear all

addpath(genpath('data'))

fn6 = 'processed_ATL06_20190102184312_00810210_001_01.h5';
slat = 'land_ice_segments/latitude';
slon = 'land_ice_segments/longitude';

beam = '/gt2l/';
lats2l = h5read(fn6,[beam slat]);
lons2l = h5read(fn6,[beam slon]);
toss = abs(lats2l) > 1e5 | abs(lons2l) > 1e5;
lats2l(toss) = [];
lons2l(toss) = [];

len = length(lats2l);
latint = interp1(1:len,lats2l,1:0.02:len);
lonint = interp1(1:len,lons2l,1:0.02:len);
depths = nan(length(latint),2);
fns = {'S2B_MSIL1C_20190102T041719_N0207_R061_T41CPV_20190102T070940.SAFE_B4_depth.tif',...
       'S2B_MSIL1C_20190102T041719_N0207_R061_T41DPA_20190102T070940.SAFE_B4_depth.tif'};

for i = 1:2
    fn = fns{i};
    [A,R] = geotiffread(fn);
    info = geotiffinfo(fn);

    [height, width]= size(A);
    [rows,cols] = meshgrid(1:width,1:height);
    [x,y] = pix2map(info.RefMatrix, rows, cols);
    [xgt,ygt] = projfwd(info,latint,lonint);
    interp = interp2(y, x, double(A)', ygt, xgt);
    depths(:,i) = interp;
end

depthpope = nanmean(depths');
latspope = latint;
save data/popedata.mat latspope depthpope

% %%
% fig = figure(1);
% set(fig,'units','normalized','outerposition',[0 0 1 1])
% smallA = A(1:10:width,1:10:height);
% smallX = x(1:10:height,1:10:width);
% smallY = y(1:10:height,1:10:width);
% %[X,Y] = meshgrid(smallX,smallY);
% pc = pcolor(smallX,smallY,smallA);
% %pc = pcolor(smallA);
% cols = [linspace(1,0,300)' linspace(1,0,300)' ones(300,1)];
% colormap(cols);
% %pc = pcolor(A(1:10:width,1:10:height));
% set(pc, 'EdgeColor', 'none');
% 
% hold on 
% plot(xgt,ygt,'r-','linewidth',3)
% 
% 
% latspope = lats2l;
% depthpope = interp;
% save data/popetest.mat latspope depthpope

