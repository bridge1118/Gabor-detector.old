%
% Second version extract an area as features (if extend==0 => single area)
% multi part (common part=5)
%

close all;clear all;clc;

addpath(genpath('app'));
addpath(genpath('src'));
load('commonSketch2.mat');

%
% Variables
centerx = selectedx + centerx;
centery = selectedy + centery;
no = 20;
extend = 0;
freq = 1/9;
f = 6;
o = 4;

%
% Part Variables
PART = length( centerx );
bayesS = cell( PART, 1 );

%% Training Stage
disp('----------Training Stage----------');
images = ReadImages( 'src/train', no, 1 );
[images, gaborBank] = FilterImages( images, freq, f, o );


for part = 1 : PART

    % Construct feature matrix of an area
    features = cell(2*extend+1, 2*extend+1);
    for i = -extend : extend
        for j = -extend : extend
            features{i+extend+1,j+extend+1} = ...
                CreateFeatureMatrix( images, centery(part)+i, centerx(part)+j, f, o );
        end
    end

    % Formate GMM input
    dTrain = [];% zeros(size, 2);
    cTrain = ones( (f*o*no) * (2*extend+1)*(2*extend+1), 1);
    for i = 1 : (2*extend+1)*(2*extend+1)
        dTrain = [ dTrain ; [real(features{i}(:)),imag(features{i}(:))] ];
    end

    % Training FJ-GMM
    FJ_params = { 'Cmax', 20, 'thr', 50, 'animate', 0 };
    bayesS{part} = gmmb_create(dTrain, cTrain, 'FJ', FJ_params{:});

end

clear cTrain dTrain i j FJ_params features

%% Testing Stage
disp('----------Testing Stage----------');

imageFolder = 'src/validation';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);
pdfMaps = cell(numImage, PART);

%figure
for img = 1 : numImage
    disp(['----Detecting ' num2str(img) ' of ' num2str(numImage)]);tic
    image_test = ReadAnImage( imageFolder, imageName(img).name, 1 );
    for part = 1 : PART
        disp(['-Detecting part ' num2str(part)]);
        pdfMaps{img, part} = TestStage2( image_test, freq, f, o, bayesS{part} );
    end
    
    disp(['elapsed time: ' num2str(toc) ' seconds']);
end


%% Threshold
pdfMaps2 = pdfMaps;
for img = 1 : numImage
    for part = 1 : PART
        mx = max(pdfMaps2{img,part}(:));
        mx = mx * .7;
        pdfMaps2{img,part}( find(pdfMaps2{img,part}<mx) ) = 0;
    end
end

%%
figure
first = 10;
last  = 12;
image_test2 = ReadImages( 'src/validation', no, 1 );
for img = first : last
    for p = 1 : 5
        subplot(6,5,(img-first)*10+p+5)
        imagesc(pdfMaps2{img,p}), hold on
        plot( centery(p), centerx(p), 'ro' )
        hold off
        
        subplot(6,5,(img-first)*10+p)
        imshow(image_test2(img).original), hold on
        plot( centery(p), centerx(p), 'ro' )
        hold off
    end
end
return


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
    plot( centery(1), centerx(1), 'ro' )
    hold off
end

%%
figure
for part = 1 : PART
    subplot(5, 1, part)
    imshow(images(img).original), hold on
    plot( centery(part), centerx(part), 'ro' )
    hold off
end

%%
figure
for part = 1 : PART
    subplot(5,1,part), imagesc(pdfMaps{img,part});
end