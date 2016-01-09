function [ G ] = CreateFeatureMatrix( images, x0, y0, f, o )

%
% Construct Feature Matrix G
%fprintf('Creating Feature Matrix...');
rows = f;
cols = o;
G = zeros(length(images), rows, cols);

for idx = 1 : length(images)
    for p = 1 : size(G,2)
        for q = 1 : size(G,3)
            G(idx, p,q) = images(idx).fResp(x0,y0,p*q);
        end
    end
    s = G(idx, :,:).^2;
    G(idx, :,:) = G(idx, :,:) ./ sqrt(sum(s(:)));
end
%fprintf('Done!\n');
