%
% First version single location to extract feature
%

close all;
clear all;
clc;

addpath(genpath('app'));
addpath(genpath('src'));

%
% Variables
no = 20;
center = [47, 64]; % (row, cal)
extend = 2; % area = (2n+1)*(2n+1)
freq = 1/20;
f = 6;
o = 6;

%% Training Stage
disp('----------Training Stage----------');
images = ReadImages( 'src/positive', no, 1 );
[images, gaborBank] = FilterImages( images, freq, f, o );


% Construct feature matrix of an area
Gtr = CreateFeatureMatrix( images, 60, 5, f, o );

% Formate GMM input
% train
dTrain = zeros(f*o*no, 2);
cTrain = ones( f*o*no, 1);
dTrain(:,1) = real( Gtr(:) );
dTrain(:,2) = imag( Gtr(:) );

% Training FJ-GMM
FJ_params = { 'Cmax', 20, 'thr', 50, 'animate', 1 };
bayesS = gmmb_create(dTrain, cTrain, 'FJ', FJ_params{:});


%% Testing Stage
disp('----------Testing Stage----------');

images_test = ReadImages( 'src/validation', 1, 1 );
images_test = FilterImages( images_test, freq, f, o );

% Construct feature matrix
%Gte = CreateFeatureMatrix( images_test, 10, 10, f, o );

% Formate GMM input
% test
%dTest = zeros(f*o*1, 2);
%cTest = ones( f*o*1, 1);
%dTest(:,1) = real( Gte(:) );
%dTest(:,2) = imag( Gte(:) );
dTest = zeros(f*o*size(images_test.im,1)*size(images_test.im,2), 2);
dTest(:,1) = real( images_test.fResp(:) );
dTest(:,2) = imag( images_test.fResp(:) );

% PDF test / Bayesian case
fprintf('Classfying...');
pdfmat = gmmb_pdf(dTest, bayesS);
%postprob = gmmb_normalize( gmmb_weightprior(pdfmat, bayesS) );
%result = gmmb_decide(postprob);
fprintf('Done!\n');

%% Results Display
% Reshape
final = zeros(size(images_test.im,1), size(images_test.im,2));
figure
for p = 0 : f*o-1

    l = size(images_test.im,1)*size(images_test.im,2);
    %range = pdfmat(p*l+1:(p+1)*l);
    %range = log( range );
    %range = range ./ sum(range);
    %final = final + reshape( pdfmat(p*l+1:(p+1)*l), ...
    %    size(images_test.im,1), size(images_test.im,2) );
    
    
    re = reshape( pdfmat(p*l+1:(p+1)*l), ...
        size(images_test.im,1), size(images_test.im,2) );
    %re = log( re );
    %re = re ./ sum( re(:) );
    final = final + re;
    
    subplot(6,6,p+1),imagesc(re)
    
    %p+1
    %input('<press enter>');
end
figure
final = final ./ (f*o);
imagesc(final);

figure
m = mean(final(:));
final( find(final<m) )=0;
imagesc(final)