%
% Second version extract an area as features (if extend==0 => single area)
%

close all;
clear all;
clc;

addpath(genpath('app'));
addpath(genpath('src'));
load('commonSketch2.mat');
%
% Variables
no = 20;

center = [47, 64]; % (row, cal) or (y,x)
extend = 0; % area = (2n+1)*(2n+1)

freq = 1/20;
f = 1;
o = 6;

%% Training Stage
disp('----------Training Stage----------');
images = ReadImages( 'src/train', no, 1 );
[images, gaborBank] = FilterImages( images, freq, f, o );

% Construct feature matrix of an area
features = cell(2*extend+1, 2*extend+1);
for i = -extend : extend
    for j = -extend : extend
        features{i+extend+1,j+extend+1} = ...
            CreateFeatureMatrix( images, center(2)+i, center(1)+j, f, o );
    end
end

% Formate GMM input
dTrain = [];% zeros(size, 2);
cTrain = ones( (f*o*no) * (2*extend+1)*(2*extend+1), 1);
for i = 1 : (2*extend+1)*(2*extend+1)
    dTrain = [ dTrain ; [real(features{i}(:)),imag(features{i}(:))] ];
end

% Training FJ-GMM
FJ_params = { 'Cmax', 20, 'thr', 50, 'animate', 1 };
bayesS = gmmb_create(dTrain, cTrain, 'FJ', FJ_params{:});

clear cTrain i j no

%% Testing Stage
disp('----------Testing Stage----------');

imageFolder = 'src/validation';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);

pdfMaps = cell(numImage,1);
time = [];
%figure
for img = 1 : numImage
    disp(['----Detecting ' num2str(img) ' of ' num2str(numImage)]);tic
    image_test = ReadAnImage( imageFolder, imageName(img).name, 1 );
    pdfMaps{img} = TestStage2( image_test, freq, f, o, bayesS );
    disp(['elapsed time: ' num2str(toc) ' seconds']);
    time = [ time ; toc ];
    %subplot(5,4,img), imshow(image_test.original);
end


%%
figure
for img = 1 : numImage
    subplot(5,4,img), imagesc(pdfMaps{img});
end

%%
figure
for img = 1 : numImage
    subplot(5,4,img)
    imshow(images(img).original), hold on
    plot( center(2), center(1), 'ro' )
    hold off
end
