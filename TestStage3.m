function [ bhaMap ] = TestStage3( images_test, freq, f, o, extend, featuresHist )

images_test = FilterImages( images_test, freq, f, o );

% Bhattacharyya distance
fprintf('Classfying...');
bhaMap = zeros( size(images_test.im,1), size(images_test.im,2) );

for p = extend+1 : size(images_test.im,1)-extend
    for q = extend+1 : size(images_test.im,2)-extend
        % feature format
        for i = -extend : extend
            for j = -extend : extend
                tmp_features{i+extend+1,j+extend+1} = ...
                    CreateFeatureMatrix( images_test, p+i, q+j, f, o );
            end
        end
        testHist = [];
        for i = 1 : (2*extend+1)^2
            testHist = [ testHist ; tmp_features{i}(:) ];
        end
        %
        [val, ind] = max(testHist);
        if val ~= 1
            testHist = [ testHist(ind:end) ; testHist(1:ind) ];
        end
        %
        bhaMap(p,q) = bhattacharyya(featuresHist, testHist);
    end
end
bhaMap = bhaMap(extend+1:end-extend, extend+1:end-extend);
fprintf('Done!\n');
