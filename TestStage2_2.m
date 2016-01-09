function [ pdfMap, dTest ] = TestStage2( images_test, freq, f, o, bayesS )

images_test = FilterImages( images_test, freq, f, o );

% PDF test (Bayesian case)
fprintf('Classfying...');
pdfMap = zeros( size(images_test.im,1), size(images_test.im,2) );

extend = 1;

for i = 1+extend : size(images_test.im,1)-extend
    for j = 1+extend : size(images_test.im,2)-extend
        
        features = cell( (2*extend+1)^2, 1 );
        count = 1;
        for p = -extend : extend
            for q = -extend : extend
                features{count,1} = ...
                    GetFeatureMatrix( images_test.fResp, i+p, j+q, f, o );
                count = count +1;
            end
        end
        
        dTest = [];
        for idx = 1 : length(features)
            dTest = [ dTest ; features{idx}(:) ];
        end
        %size(dTest)
        pdfmat = gmmb_pdf([real(dTest),imag(dTest)], bayesS);
        pdfmat2= sort( pdfmat, 'descend' );
        
        pdfMap(i,j) = sum( pdfmat2(:) ) / length(pdfmat2);
        
    end
end
fprintf('Done!\n');