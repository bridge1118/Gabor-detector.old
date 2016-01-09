%
% Same as second version but detecting with Bhattacharyya distance
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
extend = 2; % area = (2n+1)*(2n+1)

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
        features{i+extend+1,j+extend+1} = ...
            sum( features{i+extend+1,j+extend+1}(:,:,:) ) ./ no;
    end
end

featuresHist = [];
for i = 1 : (2*extend+1)^2
    featuresHist = [ featuresHist ; features{i}(:) ];
end

[val, ind] = max(featuresHist);
if val ~= 1
    featureHist = [ featuresHist(ind:end) ; featuresHist(1:ind) ];
end

clear i j

%% Testing Stage
disp('----------Testing Stage----------');

imageFolder = 'src/validation';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);

bhaMaps = cell(numImage,1);
time = [];
for img = 1 : numImage
    disp(['----Detecting ' num2str(img) ' of ' num2str(numImage)]);tic
    image_test = ReadAnImage( imageFolder, imageName(img).name, 1 );
    bhaMaps{img} = TestStage3( image_test, freq, f, o, extend, featuresHist );
    disp(['elapsed time: ' num2str(toc) ' seconds']);
    time = [ time ; toc ];
end

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
