function [outWindows] = getColorModel(inWindows,wSize)
%GETCOLORMODEL Summary of this function goes here
%   Detailed explanation goes here
%%
windows = inWindows;
windowSize = size(windows,2);
for i=1:windowSize
    K = rgb2lab(windows{i}.Image);
    L_ = K(:,:,1);
    a_ = K(:,:,2);
    b_ = K(:,:,3);

    K_ = [reshape(L_,[(wSize+1) * (wSize+1) 1]) reshape(a_,[(wSize+1)*(wSize+1) 1]) reshape(b_,[(wSize+1)*(wSize+1) 1])];

    L_fg = L_(windows{i}.FgMask==1);
    a_fg = a_(windows{i}.FgMask==1);
    b_fg = b_(windows{i}.FgMask==1);
    X_fg = [L_fg a_fg b_fg];

    L_bg = L_(windows{i}.BgMask==1);
    a_bg = a_(windows{i}.BgMask==1);
    b_bg = b_(windows{i}.BgMask==1);
    X_bg = [L_bg a_bg b_bg];

%%
options = statset('MaxIter',500);
GMM_fg = fitgmdist(X_fg,3,'RegularizationValue',0.1, 'Options', options);
GMM_bg = fitgmdist(X_bg,3,'RegularizationValue',0.1, 'Options', options);

f = cdf(GMM_fg,K_);
b = cdf(GMM_bg,K_);
% 
f_ = reshape(f, [wSize+1 wSize+1]);
b_ = reshape(b, [wSize+1 wSize+1]);

fb = f_ ./ (f_ + b_);
windows{i}.FgProbability = fb;
sprintf(['generated ' num2str(i)])
end


outWindows = windows;
end

