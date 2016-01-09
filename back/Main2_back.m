%
% Second version extract an area as features
% TestStage is not a function but in main function
%

close all;
clear all;
clc;

addpath(genpath('app'));
addpath(genpath('src'));

%
% Variables
no = 20;

center = [47, 64]; % (row, cal) or (y,x)
extend = 1; % area = (2n+1)*(2n+1)

freq = 1/20;
f = 6;
o = 6;

%% Training Stage
disp('----------Training Stage----------');
images = ReadImages( 'src/positive', no, 1 );
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

images_test = ReadImages( 'src/validation', 1, 1 );
images_test = FilterImages( images_test, freq, f, o );

% PDF test (Bayesian case) / Bhattacharyya distance
fprintf('Classfying...');
pdfMap = zeros( size(images_test.im,1), size(images_test.im,2) );
%bhaMap = zeros( size(images_test.im,1), size(images_test.im,2) );

for i = 1 : size(images_test.im,1)
    for j = 1 : size(images_test.im,2)
        % feature format
        tmp_feature = CreateFeatureMatrix( images_test, i, j, f, o );
        % pdf
        pdfmat = gmmb_pdf( ...
            [real(tmp_feature(:)),imag(tmp_feature(:))], bayesS);
        pdfMap(i,j) = sum( pdfmat );
        
        clear tmp_feature pdfmat
    end
end
fprintf('Done!\n');
clear i j

%% Results Display
figure, imagesc(pdfMap);

figure
m = mean( pdfMap(:) );
pdfMap( find(pdfMap<m) )=0;
imagesc(pdfMap)

clear m
clear center dTrain extend f freq  images o