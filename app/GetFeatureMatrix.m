function [ Gtmp ] = GetFeatureMatrix( im, r, c, m, n )

Gtmp = zeros(m, n);
for p = 1 : size(Gtmp,1)
    for q = 1 : size(Gtmp,2)
        Gtmp(p,q) = im(r,c,p*q);
    end
end
s = Gtmp.^2;
Gtmp = Gtmp ./ sqrt( sum(s(:)) );