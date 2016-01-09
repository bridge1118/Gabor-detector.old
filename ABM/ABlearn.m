% SHARED SKETCH ALGORITHM FOR LEARNING ACTIVE BASIS

%% Load in exponential model, mex C codes, and set parameters
% ExponentialModel; % this line is not needed if 'storedExponentialModel' exists
clear; close all; clc
load 'storedExponentialModel'; % load in exponential model 
mex CsharedSketch.c; % learning by shared sketch algorithm
mex Csigmoid.c; % sigmoid transformation after filtering
epsilon = .01; % allowed correlation between selected Gabors 
locationShiftLimit = 4; % shift in normal direction 
orientShiftLimit = 1; % shift in orientation
numElementLimit = 5; % limit on number of Gabors in active basis   
responseLimit = 0.; % lower limit on average response of selected basis elements, you can set it to zero if you really want numElementLimit elements
numElementPointer = zeros(1, 2); % actual number selected, we use a pointer just to pass the number
Correlation = CorrFilter(allFilter, epsilon); % correlation between filters 
rotateShiftLimit = 4; numRotate = 2*rotateShiftLimit + 1; % limit of rotation of the learned template in detection
flipOrNot = 1; % left-right flip of the template, 0 or 1
outputFolder = 'catRotateFlip';

%% Load in training images
%imageOption = 1; resizeFactor = .6; % resize images to specified ratio, and use the common upper-left portion 
imageOption = 2; sizex = 100; sizey = 100; % resize images to specified common height and width
%imageOption = 3; sizey = 120; % resize images to have common width without changing their aspect ratios, and use the common horizontal central line
imageFolder = '../src/train'; % folder of training images  
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1); % number of training images 
I = cell(1, numImage); 
LoadImage; 
allSizex = zeros(1, numImage)+sizex; 
allSizey = zeros(1, numImage)+sizey; 

%% Compute SUM1 maps by Gabor filtering and sigmoid transformation
disp(['**************** start filtering training images']); tic
if (imageOption == 3) 
    [SUM1map, Ifill] = ApplyFilterfftFill(I, allFilter, localHalfx, localHalfy, thresholdFactor); % SUM1 maps by Gabor filtering
    I = Ifill; 
else 
    SUM1map = ApplyFilterfftSame(I, allFilter, localHalfx, localHalfy, -1, thresholdFactor);% SUM1 maps by Gabor filtering
end
Csigmoid(numImage, allSizex, allSizey, numOrient, saturation, SUM1map);
disp(['filtering time: ' num2str(toc) ' seconds']);

%% Prepare output variables for learning
selectedOrient = zeros(1, numElementLimit);  % orientations  of selected Gabors
selectedx = zeros(1, numElementLimit); % locations of selected Gabors
selectedy = zeros(1, numElementLimit); 
selectedlambda = zeros(1, numElementLimit); % weighting parameter for scoring template matching
selectedLogZ = zeros(1, numElementLimit); % normalizing constant
commonTemplate = single(zeros(sizex, sizey)); % template of active basis 
deformedTemplate = cell(1, numImage); % templates for training images
%deformedCenterx = cell(numElementLimit, numImage);
%deformedCentery = cell(numElementLimit, numImage);
for (img = 1 : numImage)
    deformedTemplate{img} = single(zeros(sizex, sizey));  
end
SUM2score = zeros(numImage, 1); % template matching scores for training images 

%% Learning by shared sketch algorithm
disp(['**************** start mex-C learning']); tic
CsharedSketch(numOrient, locationShiftLimit, orientShiftLimit, ... % about active basis  
       numElementLimit, numElementPointer, responseLimit, numImage, sizex, sizey, SUM1map, ... % about training images 
       halfFilterSize, Correlation, allSymbol(1, :), ... % about filters
       numStoredPoint, storedlambda, storedExpectation, storedLogZ, ... % about exponential model 
       selectedOrient, selectedx, selectedy, selectedlambda, selectedLogZ, ... % learned parameters
       commonTemplate, deformedTemplate); % learned templates 
numElement = numElementPointer(1); 
disp(['mex-C learning time: ' num2str(toc) ' seconds']);

OutLearningResult; 
RotateTemplate;
%save '../deformedTemplate5' deformedTemplate
%save '../commonSketch2' selectedx selectedy centerx centery

return

%% Rotate and flip template, display and save results
OutLearningResult; 
RotateTemplate;
save 'learnedTemplate' outputFolder numElement allSelectedOrient allSelectedx allSelectedy selectedlambda selectedLogZ ...
      numOrient halfFilterSize allFilter allSymbol locationShiftLimit orientShiftLimit saturation ...
      localHalfx localHalfy thresholdFactor ...
      rotateShiftLimit numRotate flipOrNot
 