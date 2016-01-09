function images = ReadImages( path, normalize )

fprintf('Reading the images...');

%
% Parameter setting
imName = dir( [path '/*.jpg'] );

%
% Variables
name = zeros(no, 1);

%
% Output strust
field1 = 'name';
value1 = [];
field2 = 'im';
value2 = [];
field3 = 'original';
value3 = [];
s = struct(field1, value1, field2, value2, field3, value3);
images(no) = s;

%
% Read images and assign values to struct
for idx = 1 : no
    im = imread([ path '/' imName(idx).name ]);
    im = imresize(im, [100 100]);
    images(idx).original = im;
    images(idx).name = imName(idx).name;
end

%
% RGB to gray
for idx = 1 : length(images)
    images(idx).im = rgb2gray(images(idx).original);
end

%
% Normalize
if ( normalize == 0 )
    return
end
for idx = 1 : length(images)
    images(idx).im = double(images(idx).im) / 255;
end

fprintf('Done!\n');
