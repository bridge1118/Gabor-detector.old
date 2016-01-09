%
% Same as second version but detecting with Bhattacharyya distance
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

clear i j

%% Testing Stage
disp('----------Testing Stage----------');
images_test = ReadImages( 'src/validation', 1, 1 );
images_test = FilterImages( images_test, freq, f, o );

% Bhattacharyya distance
fprintf('Classfying...');
bhaMap = zeros( size(images_test.im,1), size(images_test.im,2) );

for p = extend+1 : size(images_test.im,1)-extend
    for q = extend+1 : size(images_test.im,2)-extend
        % feature format
        for i = -extend : extend
            for j = -extend : extend
                tmp_features{i+extend+1,j+extend+1} = ...
                    CreateFeatureMatrix( images_test, p+i, q+j, f, o );
            end
        end
        testHist = [];
        for i = 1 : (2*extend+1)^2
            testHist = [ testHist ; tmp_features{i}(:) ];
        end
        bhaMap(p,q) = bhattacharyya(featuresHist, testHist);
    end
end
bhaMap = bhaMap(extend+1:end-extend, extend+1:end-extend);
fprintf('Done!\n');
clear i j p q

%% Results Display
figure, imagesc(bhaMap);

clear m
clear center dTrain extend f freq  images o
%input('<press enter>');
return
%%
for i = 1 : no
    close all
    imshow(images(i).original), hold on
    plot(center(2),center(1), 'r+'), hold off
    input('<press enter>');
end
clear i
