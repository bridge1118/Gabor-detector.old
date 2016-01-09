[y x co] = size(pic);
figure('Units','Pixels','Resize','off',...
 'Position',[100 100 x y],'PaperUnit','points',...
 'PaperPosition',[0 0 x y]);
 axes('position',[0 0 1 1]);
imshow(pic, []);
axis off