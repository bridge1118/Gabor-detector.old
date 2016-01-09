%% Load in training images
maxSizex = 0; 
for (img = 1 : numImage)
    tmpIm = imread([imageFolder '/' imageName(img).name]); 
    if size(tmpIm,3) == 3
        tmpIm = rgb2gray(tmpIm);
    end
    if (imageOption == 1)
       I{img} = imresize(single(tmpIm), resizeFactor, 'nearest');
    end
    if (imageOption == 2)
       I{img} = imresize(single(tmpIm), [sizex sizey], 'nearest');     
    end
    if (imageOption == 3)
          [sx, sy] = size(tmpIm); 
          sizex = round(sx*sizey/sy); 
          if (maxSizex<sizex)
            maxSizex = sizex; 
          end
          I{img} = imresize(single(tmpIm), [sizex sizey], 'nearest');             
    end     
end
if (imageOption == 1)   
    imageSize = zeros(numImage, 2);
    for (img = 1 : numImage)
      imageSize(img, :) = size(I{img});   
    end
    sizex = min(imageSize(:, 1)); sizey = min(imageSize(:, 2)); 
    for (img = 1 : numImage)
      I{img} = I{img}(1:sizex, 1:sizey); 
    end
end
if (imageOption == 3)
   sizex = maxSizex; 
end
disp(['number of training images = ' num2str(numImage)]);


