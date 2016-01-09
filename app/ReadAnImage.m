function image = ReadAnImage( path, name, normalize )

fprintf('Reading an input image...');

%
% Output strust
field1 = 'name';
value1 = [];
field2 = 'im';
value2 = [];
field3 = 'original';
value3 = [];
s = struct(field1, value1, field2, value2, field3, value3);
image(1) = s;

%
% Read images and assign values to struct
im = imread([ path '/' name ]);
im = imresize(im, [100 100]);
image(1).original = im;
image(1).name = name;

%
% RGB to gray
if size(image(1).im,3) == 3
    image(1).im = rgb2gray(image(1).original);
else
    image(1).im = image(1).original;
end
%
% Normalize
if ( normalize == 0 )
    return
end
image(1).im = double(image(1).im) / 255;

fprintf('Done!\n');
