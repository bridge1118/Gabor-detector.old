%
% Same as second version but detecting with Bhattacharyya distance
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
freq = 1/20;
f = 2;
o = 6;

%
% Part Variables
PART = length( centerx );
featuresHist = cell( PART, 1 );

%% Training Stage
disp('----------Training Stage----------');
images = ReadImages( 'src/train', no, 1 );
[images, gaborBank] = FilterImages( images, freq, f, o );

% Construct feature matrix of an area
for part = 1 : PART
    features = cell(2*extend+1, 2*extend+1);
    for i = -extend : extend
        for j = -extend : extend
            features{i+extend+1,j+extend+1} = ...
                CreateFeatureMatrix( images, centery(part)+i, centerx(part)+j, f, o );
            features{i+extend+1,j+extend+1} = ...
                sum( features{i+extend+1,j+extend+1}(:,:,:) ) ./ no;
        end
    end

    for i = 1 : (2*extend+1)^2
        featuresHist{part} = [ featuresHist{part} ; features{i}(:) ];
    end

    [val, ind] = max(featuresHist{part});
    if val ~= 1
        featureHist{part} = [ featuresHist{part}(ind:end) ; featuresHist{part}(1:ind) ];
    end
end
clear i j gaborBank part features ind val 


%% Testing Stage
disp('----------Testing Stage----------');

imageFolder = 'src/validation';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);
numImage = 3
bhaMaps = cell(numImage, PART);

for img = 1 : numImage
    disp(['----Detecting ' num2str(img) ' of ' num2str(numImage)]);tic
    image_test = ReadAnImage( imageFolder, imageName(img).name, 1 );
    for part = 1 : PART
        disp(['-Detecting part ' num2str(part)]);
        bhaMaps{img,part} = ...
            TestStage3( image_test, freq, f, o, extend, featuresHist{part} );
    end
    
    disp(['elapsed time: ' num2str(toc) ' seconds']);
end

%% Threshold
bhaMaps2 = bhaMaps;
for img = 1 : numImage
    for part = 1 : PART
        mx = max(bhaMaps2{img,part}(:));
        mx = mx * .5;
        bhaMaps2{img,part}( find(bhaMaps2{img,part}<mx) ) = 0;
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
        imagesc(bhaMaps2{img,p}), hold on
        plot( centery(p), centerx(p), 'ro' )
        hold off
        
        subplot(6,5,(img-first)*10+p)
        imshow(image_test2(img).original), hold on
        plot( centery(p), centerx(p), 'ro' )
        hold off
    end
end
return

%% Results Display
figure
for img = 1 : numImage
    subplot(5,4,img), imagesc(bhaMaps{img});
end
return

%%
for i = 1 : no
    close all
    imshow(images(i).original), hold on
    plot(center(2),center(1), 'r+'), hold off
    input('<press enter>');
end
clear i
