function [ pdfMap ] = TestStage2( images_test, freq, f, o, bayesS )

images_test = FilterImages( images_test, freq, f, o );

% PDF test (Bayesian case)
fprintf('Classfying...');
pdfMap = zeros( size(images_test.im,1), size(images_test.im,2) );

for i = 1 : size(images_test.im,1)
    for j = 1 : size(images_test.im,2)
        % feature format
        tmp_feature = CreateFeatureMatrix( images_test, i, j, f, o );
        tmp = [real(tmp_feature(:)),imag(tmp_feature(:))]';
        K = 10;
        [eigenVector,score,eigenvalue,tsquare] = princomp( tmp );
        transMatrix = eigenVector(:,1:K);
        tmp = tmp * transMatrix;
        tmp = tmp';
        % pdf
        pdfmat = gmmb_pdf( tmp, bayesS);
        %pdfmat = gmmb_normalize( gmmb_weightprior(pdfmat', bayesS) );
        pdfmat2= sort( pdfmat, 'descend' );
        %pdfmat2= pdfmat2(6:end);
        %pdfmat2= pdfmat2 ./ sqrt(sum(pdfmat2.^2));
        
        pdfMap(i,j) = sum( pdfmat2(:) )/(f*o);
        
        clear tmp_feature pdfmat
    end
end
fprintf('Done!\n');