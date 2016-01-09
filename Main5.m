%
% Third version extract 'ellipse' area as features (if extend==0 => single area)
% multi part (deform part=5)
%
close all;clear all;clc;

addpath(genpath('app'));
addpath(genpath('src'));
load('deformedTemplate');

%
% Variables
no = 20;
freq = 1/9;
m = 6;
n = 4;

%
% Part Variables
PART = size(deformedTemplate,1);
bayesS = cell( PART, 1 );

%% Training Stage
disp('----------Training Stage----------');
images = ReadImages( 'src/train', no, 1 );
images = FilterImages( images, freq, m, n );
dTrain = cell(PART,1);
for part = 1 : PART
    
    Gs = cell( length(images), 1 );
    % Create feature matrix Gs
    for idx = 1 : length(images)
        
        [rows, cals, z] = find( deformedTemplate{part, idx} );
        G_ = cell( 1,length(rows) );
        for r = 1 :  length(rows)
            G_{r} = GetFeatureMatrix(images(idx).fResp,rows(r),cals(r),m,n);  
        end
        Gs{idx} = G_;
        clear G_ rows cals z r
    
    end
    clear idx    
    
    % Formate GMM input
    dTrain{part} = [];% zeros(size, 2);
    for img = 1 : length(images)
        for idx = 1 : length( Gs{img} )
            tmp = [ real(Gs{img}{idx}(:)), imag(Gs{img}{idx}(:)) ];
            dTrain{part} = [ dTrain{part} ; tmp ];
        end
    end
    cTrain = ones( length(dTrain{part}),1 );
    clear idx img tmp
    
    % Train FJ-GMM
    FJ_params = { 'Cmax', 10, 'thr', 50, 'animate', 0 };
    bayesS{part} = gmmb_create(dTrain{part}, cTrain, 'FJ', FJ_params{:});

end
%[eigenVector,score,eigenvalue,tsquare] = princomp( dTrain{1}' );
clear part cTrain FJ_params

%% Testing Stage
disp('----------Testing Stage----------');

imageFolder = 'src/validation';
imageName = dir([imageFolder '/*.jpg']);
numImage = size(imageName, 1);
pdfMaps = cell(numImage, PART);
dTest   = cell(numImage, PART);
%%%%%%%%%%%%%%%%%%
numImage = 5;

for img = 1 : numImage
    disp(['----Detecting ' num2str(img) ' of ' num2str(numImage)]);tic
    image_test = ReadAnImage( imageFolder, imageName(img).name, 1 );
    
    for part = 1 : PART
        disp(['-Detecting part ' num2str(part)]);
        %[pdfMaps{img, part}, dTest{img, part}] = TestStage2_2( image_test, freq, m, n, bayesS{part} );
        pdfMaps{img, part} = TestStage2( image_test, freq, m, n, bayesS{part} );
    end
    
    disp(['elapsed time: ' num2str(toc) ' seconds']);
    
    
    for part = 1 : PART
        figure
        imagesc( pdfMaps{img,part} );
        set(gca,'XTick',[]) % Remove the ticks in the x axis!
        set(gca,'YTick',[]) % Remove the ticks in the y axis
        set(gca,'Position',[0 0 1 1]) % Make the axes occupy the hole figure
        saveas(gcf,['/Users/ful6ru04/Desktop/pdfMap_i' num2str(img) '_p' num2str(part) '.jpg'])
        
        %imwrite( sc, ['/Users/ful6ru04/Desktop/pdfMap_i' num2str(img) '_p' num2str(part) '.jpg']);
    end
    imwrite(image_test.original, ...
        ['/Users/ful6ru04/Desktop/ori' num2str(img) '.jpg']);
    
end

return
%% Threshold
pdfMaps2 = pdfMaps;
for img = 1 : numImage
    for part = 1 : PART
        mx = max(pdfMaps2{img,part}(:));
        mx = mx * .7;
        pdfMaps2{img,part}( find(pdfMaps2{img,part}<mx) ) = 0;
    end
end

%%
figure
first = 10;
last  = 12;
image_test2 = ReadImages( 'src/validation', no, 1 );
for img = first : last
    for p = 1 : 5
        subplot(6,5,(img-first)*10+p+5)
        imagesc(pdfMaps2{img,p}), hold on
        plot( centery(p), centerx(p), 'ro' )
        hold off
        
        subplot(6,5,(img-first)*10+p)
        imshow(image_test2(img).original), hold on
        plot( centery(p), centerx(p), 'ro' )
        hold off
    end
end
return


%%
figure
for img = 1 : numImage
    subplot(5,4,img), imagesc(pdfMaps{img});
end

%%
figure
for img = 1 : numImage
    subplot(5,4,img)
    imshow(images(img).original), hold on
    plot( centery(1), centerx(1), 'ro' )
    hold off
end

%%
figure
for part = 1 : PART
    subplot(5, 1, part)
    imshow(images(img).original), hold on
    plot( centery(part), centerx(part), 'ro' )
    hold off
end

%%
figure
for part = 1 : PART
    subplot(5,1,part), imagesc(pdfMaps{img,part});
end