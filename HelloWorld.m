close all;clear all;clc;

load('deformedTemplate');

idx = 3;

imageFolder = 'src/train';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);

for idx = 15 : 20
    im = imread([imageFolder '/' imageName(idx).name]); 
    im = rgb2gray(im);
    im = imresize(im, [100 100]);

    template = deformedTemplate{1,idx} + ...
        deformedTemplate{2,idx} + deformedTemplate{3,idx} + ...
        deformedTemplate{4,idx} + deformedTemplate{5,idx} ;

    im( find(template) ) = 255;
    figure,imshow(im)
    imwrite(im, ['/Users/ful6ru04/Desktop/t' num2str(idx) '.jpg']);
end
