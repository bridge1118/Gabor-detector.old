pic = imread([imageFolder '/' imageName(img).name]); showImage;
saveas(gcf, [outputFolder 'eps/testoriginal' num2str(100+img) '.eps'], 'epsc');
saveas(gcf, [outputFolder 'png/testoriginal' num2str(100+img) '.png'], 'png');
pic = double(J{Mind}+translatedTemplate{Mind}*100); showImage;
saveas(gcf, [outputFolder 'eps/testsketch' num2str(100+img) '.eps'], 'eps');
saveas(gcf, [outputFolder 'png/testsketch' num2str(100+img) '.png'], 'png');
