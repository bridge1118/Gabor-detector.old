% SUM-MAX MAPS FOR TEMPLATE MATCHING INFERENCE
%% load in learned template
clear all; 
load 'learnedTemplate'; % load in the learned template
mex CgetMAX1.c; 
mex CgetSUM2.c;   
mex CdrawTemplate.c
%% load in test image, generate multiple resolutions
numResolution = 10;  % total number of resolutions to search 
allSizex = zeros(1, numResolution); allSizey = zeros(1, numResolution); 
MAX2score = single(zeros(1, numResolution));  % maximum log-likelihood score at each resolution
allFx = zeros(1, numResolution); allFy = zeros(1, numResolution); % detected location at each resolution   
imageFolder = 'testImage'; % folder of training images  
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1); % number of training images 
for (img = 1 : numImage)
    close all; 
    tmpIm = imread([imageFolder '/' imageName(img).name]); 
    if size(tmpIm,3) == 3
        tmpIm = rgb2gray(tmpIm);
    end
    J0 = single(tmpIm); 
    MAX1maps = cell(numResolution, numOrient); 
    SUM2map = cell(1, numResolution); 
    for(resolution=1:numResolution)
       J{resolution} = imresize(J0, .10+(resolution-1)*.1, 'nearest');  % scaled images
       [sizex, sizey] = size(J{resolution}); 
       allSizex(resolution) = sizex; allSizey(resolution) = sizey; % sizes of images at multiple resolutions     
       for (orient=1:numOrient)
          MAX1map{resolution, orient} = single(zeros(sizex, sizey)); 
       end
       SUM2map{resolution} = single(zeros(sizex, sizey));  % log-likelihood score maps for testing images
       translatedTemplate{resolution} = single(zeros(sizex, sizey));  % symbolic sketch on testing image
     end
%% compute SUM1 maps for all resolutions
disp(['======> start filtering image ' num2str(img)]); tic
SUM1map = ApplyFilterfft(J, allFilter, localHalfx, localHalfy, thresholdFactor); % filtering images at multiple resolutions
Csigmoid(numResolution, allSizex, allSizey, numOrient, saturation, SUM1map);
disp(['filtering time: ' num2str(toc) ' seconds']);
%% compute MAX1 maps for all resolutions
disp(['start maxing']); tic
CgetMAX1(numResolution, allSizex, allSizey, numOrient,  ...
                     locationShiftLimit, orientShiftLimit, ...
                     SUM1map, MAX1map);
disp(['maxing time: ' num2str(toc) ' seconds']);   
%% detect the object and superpose template
disp(['start finding']); tic
MMAX2 = -1e10; 
for (flip = 0 : flipOrNot)
   for (rot = -rotateShiftLimit : rotateShiftLimit)
         r = rot+rotateShiftLimit+1 + (rotateShiftLimit*2+1)*flip;           
         CgetSUM2(numResolution, allSizex, allSizey, numOrient, ...
              numElement, allSelectedOrient(r, :), allSelectedx(r, :), allSelectedy(r, :), selectedlambda, selectedLogZ, ...
              MAX1map, SUM2map, MAX2score, allFx, allFy);        
         [maxOverResolution ind] = max(MAX2score);   % most likely resolution
         if (MMAX2 < maxOverResolution) 
               MMAX2 = maxOverResolution; Mrot = rot; Mflip = flip; 
               Mind = ind; MFx = allFx(ind); MFy = allFy(ind); 
         end
   end
end
r = Mrot+rotateShiftLimit+1 + (rotateShiftLimit*2+1)*Mflip;  
CdrawTemplate(numResolution, allSizex, allSizey, numOrient, ...
              locationShiftLimit, orientShiftLimit, ...
              halfFilterSize, SUM1map, allSymbol(1, :), ...
              numElement, allSelectedOrient(r, :), allSelectedx(r, :), allSelectedy(r, :), ...
              translatedTemplate, Mind, MFx, MFy);
disp(['mex-C finding time: ' num2str(toc) ' seconds']);
OutdetectTemplate; 
end
Outhtml; 

