fid = fopen([outputFolder '.html'], 'at'); 
   outMessage =  ['==> Number of testing images = ' num2str(numImage) ...
                          '; Range of rotation = ' num2str(rotateShiftLimit) ' times pi/15'  ...
                          '; FlipOrNot = ' num2str(flipOrNot) ...
                          '<br>'];
    fprintf(fid, '%s\n', outMessage);
    disp(outMessage);           
%% write the html code for reproducibility page
heightstr = '"height=160> '; 
counter = 0; 
for (img = 1 : numImage)
 fprintf(fid, '%s\n', ['<IMG SRC="' outputFolder 'png/testoriginal' num2str(100+img) '.png' heightstr]);
 fprintf(fid, '%s\n', ['<IMG SRC="' outputFolder 'png/testsketch' num2str(100+img) '.png' heightstr]);
 counter = counter + 1; 
 if (counter == 3)
     fprintf(fid, '%s\n', ['<br>']);
     counter = 0; 
 end
end
fprintf(fid, '%s\n', ['<hr>']);
fclose(fid);