%% Output images and sketches into png and eps folders and generate html file.   
if (0)
if (exist([outputFolder 'eps']))
    delete([outputFolder 'eps/*.*']); 
else
    mkdir([outputFolder 'eps']); 
end
if (exist([outputFolder 'png']))
    delete([outputFolder 'png/*.*']); 
else
    mkdir([outputFolder 'png']); 
end
if (exist([outputFolder '.html']))
    delete([outputFolder '.html']); 
end
fid = fopen([outputFolder '.html'], 'wt'); 
   fprintf(fid, '%s\n', ['<a href="' outputFolder 'Code.zip">Code and data</a> <br>']);
   outMessage =  ['==> Number of training images = ' num2str(numImage) ...
                          '; Number of elements = ' num2str(numElement) ...
                          '; Length of Gabor = ' num2str(halfFilterSize*2+1) ' pixels' ...
                          '; Range of displacement = ' num2str(locationShiftLimit) ' pixels' ...
                          '; Image height and width = '  num2str(sizex) ' by ' num2str(sizey) ' pixels ' ...
                          '<br>'];
    fprintf(fid, '%s\n', outMessage);
    disp(outMessage);           
    fprintf(fid, '%s\n', ['<hr>']);
    heightstr0 = '"height=120> '; heightstr = '"height=120> '; length = 5;  
    pic = -double(commonTemplate); showImage; 
    saveas(gcf, [outputFolder 'eps/000template'  '.eps'], 'eps');
    saveas(gcf, [outputFolder 'png/000template'  '.png'], 'png');
    pic = commonTemplate*0.+255; showImage; 
    saveas(gcf, [outputFolder 'eps/empty.eps'], 'eps');
    saveas(gcf, [outputFolder 'png/empty.png'], 'png');   
    fprintf(fid, '%s\n', ['<IMG SRC="' outputFolder 'png/000template'  '.png' heightstr0]);
    fprintf(fid, '%s\n', ['<br>']);
    [SUM2scoresort, ind] = sort(SUM2score, 'descend'); 
    counter = 0; 
    for (i = 1 : numImage)
       this = ind(i); 
       close all; 
       pic = imread([imageFolder '/' imageName(this).name]); showImage; 
    saveas(gcf, [outputFolder 'eps/'  'I' num2str(1000+i) '.eps'], 'eps');
    saveas(gcf, [outputFolder 'png/'  'I' num2str(1000+i) '.png'], 'png');    
    pic = -(deformedTemplate{this}); showImage; 
    saveas(gcf, [outputFolder 'eps/'  'I' num2str(1000+i) 'sketch.eps'], 'eps');
    saveas(gcf, [outputFolder 'png/'  'I' num2str(1000+i) 'sketch.png'], 'png');
%% write the html code for reproducibility page
    fprintf(fid, '%s\n', ['<IMG SRC="' outputFolder 'png/'  'I' num2str(1000+i) '.png' heightstr]);
    fprintf(fid, '%s\n', ['<IMG SRC="' outputFolder 'png/'  'I' num2str(1000+i) 'sketch.png' heightstr]);
           counter = counter + 1; 
           if (counter == length)
               counter = 0; fprintf(fid, '%s\n', ['<br>']);
           end
    end %i
    fprintf(fid, '%s\n', ['<hr>']);
    fclose(fid);
end

%% Generate a big gif file to show the images and sketches.
K = numImage; bx =10; by = 10; cc = 3;  
[SUM2scoresort, ind] = sort(SUM2score); 
col = 5; row = floor(K/col)+1;
Iout = zeros(row*sizex+(row-1)*(2*bx+cc), 2*col*sizey+(col-1)*(2*by+cc))+255; 
towrite =  -commonTemplate; 
towrite = (255 * (towrite-min(towrite(:)))/(max(towrite(:))-min(towrite(:))));
Iout(1:sizex, 1:sizey) = towrite;
i = -1;  
for (r = 1 : row)
    for (c = 1 : col)
        i = i+1; 
        if ((i>=1)&&(i<=K))
                towrite = I{ind(numImage-i+1)}; 
            towrite = (255 * (towrite-min(towrite(:)))/(max(towrite(:))-min(towrite(:))));
            Iout((r-1)*sizex+1+(r-1)*(2*bx+cc): r*sizex+(r-1)*(2*bx+cc), (c-1)*2*sizey+1+(c-1)*(2*by+cc): (c-1)*2*sizey+sizey+(c-1)*(2*by+cc)) = towrite; 
            towrite =  -(deformedTemplate{ind(numImage-i+1)}); 
            towrite = (255 * (towrite-min(towrite(:)))/(max(towrite(:))-min(towrite(:))));
            Iout((r-1)*sizex+1+(r-1)*(2*bx+cc) : r*sizex+(r-1)*(2*bx+cc), (c-1)*2*sizey+sizey+(c-1)*(2*by+cc)+1 : (c-1)*2*sizey+sizey+(c-1)*(2*by+cc)+sizey) =towrite;  
        end
    end
end
for (r = 1 : row-1)
  Iout(r*sizex+(r-1)*(2*bx+cc)+bx+1:r*sizex+(r-1)*(2*bx+cc)+bx+cc, :) = 0; 
end
for (c = 1 : col-1)
  Iout(:, c*(sizey*2)+(c-1)*(2*by+cc)+by+1:c*(sizey*2)+(c-1)*(2*by+cc)+by+cc) = 0; 
end
Outepsgif(Iout, [outputFolder 'Panel'  ]);