%
% test version
%

close all;
clear all;
clc;

addpath(genpath('app'));
addpath('src');

%
% Read and normalize image
fprintf('Reading an input image...');
src = './src/positive/0000000001.jpg';
im  = imread(src);
im  = rgb2gray(im); % select only one color channel
im  = double(im)/255; % convert to double and scale to [0,1]
fprintf('Done!\n');

%
% Create Gabor filter bank
fprintf('Creating Gabor filter bank with selected parameters...');
gaborBank= sg_createfilterbank(size(im),1/4,3,4,'verbose',0);
fprintf('Done!\n');

%
% Filter with the filter bank
fprintf('Filtering...');
fResp = sg_filterwithbank(im,gaborBank);
%fResp2 = sg_filterwithbank2(im,gaborBank);
fprintf('Done!\n');

%
% Convert responses to simple 3-D matrix
fprintf('Convert responses to matrix form...');
fResp = sg_resp2samplematrix(fResp);
fResp = sg_normalizesamplematrix(fResp);
fprintf('Done!\n');

%
% Construct Feature Matrix G
x0 = 40;
y0 = 60;
rows = 3;
cols = 4;
G = zeros(rows, cols);
dTrain = zeros(rows*cols, 2);
cTrain = ones( rows*cols, 1);

for p = 1 : size(G,1)
    for q = 1 : size(G,2)
        G(p,q) = fResp(x0,y0,p*q);
    end
end
clear p q;
mr = real(G)';
mi = imag(G)';
dTrain(:,1) = mr(:);
dTrain(:,2) = mi(:);

%
% FJ-GMM
FJ_params = { 'Cmax', 20, 'thr', 50, 'animate', 1 };
bayesS = gmmb_create(dTrain, cTrain, 'FJ', FJ_params{:});
return
%
% PDF
pdfmat = gmmb_pdf(dTest, bayesS);
postprob = gmmb_normalize( gmmb_weightprior(pdfmat, bayesS) );
result = gmmb_decide(postprob);


%{
% Display responses
fprintf('Displaying input image and responses...');
close all;
subplot(1,3,1);
imagesc(im);
title('Input');
for featInd = 1:size(fResp,3)
    featInd
  subplot(1,3,2);
  imagesc(squeeze(real(fResp(:,:,featInd))));
  axis off
  title('Real');
  subplot(1,3,3);
  imagesc(squeeze(imag(fResp(:,:,featInd))));
  axis off
  title('Imaginary');
  input('<RETURN>');
end;
fprintf('Done!\n');
%}
