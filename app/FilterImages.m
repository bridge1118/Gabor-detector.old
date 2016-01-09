function [images, gaborBank] = FilterImages( images, f, m, n )

%
% Create Gabor filter bank
fprintf('Creating Gabor filter bank with selected parameters...');

gaborBank = ...
    sg_createfilterbank(size(images(1).im), ...
    f, m, n, 'k', sqrt(3), 'verbose',0);
fprintf('Done!\n');

%
% Filter with the filter bank
fprintf('Filtering...');
for idx = 1 : length(images)
    images(idx).fResp = sg_filterwithbank(images(idx).im,gaborBank);
    images(idx).fResp = sg_resp2samplematrix(images(idx).fResp);
    images(idx).fResp = sg_normalizesamplematrix(images(idx).fResp);
end
fprintf('Done!\n');
