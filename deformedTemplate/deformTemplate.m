close all; clear all; clc

load('deformedTemplate');

imageFolder = '../src/train';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);
images = cell(1, numImage);
PART = 5;

for idx = 1 : numImage
    images{idx} = imread([imageFolder '/' imageName(idx).name]); 
    images{idx} = imresize(images{idx}, [100 100]);
end
a = zeros(100,100);
for part = 1 : PART
    a = a + deformedTemplate{part, 1};
end

figure
for idx = 1 : 5
    for part = 1 : PART
        subplot(5, PART, (idx-1)*5+part), imshow( deformedTemplate{part, idx} )
        %input('<press enter>');
    end
end

%{
load('deformedTemplate1');
load('deformedTemplate2');
load('deformedTemplate3');
load('deformedTemplate4');
load('deformedTemplate5');
%}
%{
deformedTemplate = cell(5,20);

for idx = 1 : numImage
    deformedTemplate{1,idx} = deformedTemplate1{idx};
    deformedTemplate{2,idx} = deformedTemplate2{idx}-deformedTemplate1{idx};
    deformedTemplate{3,idx} = deformedTemplate3{idx}-deformedTemplate2{idx};
    deformedTemplate{4,idx} = deformedTemplate4{idx}-deformedTemplate3{idx};
    deformedTemplate{5,idx} = deformedTemplate5{idx}-deformedTemplate4{idx};
end
clear deformedTemplate1 deformedTemplate2 deformedTemplate3 ...
    deformedTemplate4 deformedTemplate5
save 'deformedTemplate' deformedTemplate
%}