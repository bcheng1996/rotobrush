function [outWindows] = updateColorModel(inWindows,prevWindows,wSize)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%%
%temp
windows = inWindows;
windowSize = size(windows,2);
fg_thresh = 0.75;
bg_thresh = 0.2;
for i=1:windowSize
    K = rgb2lab(windows{i}.Image);
    L_ = K(:,:,1);
    a_ = K(:,:,2);
    b_ = K(:,:,3);

    K_ = [reshape(L_,[(wSize+1) * (wSize+1) 1]) reshape(a_,[(wSize+1)*(wSize+1) 1]) reshape(b_,[(wSize+1)*(wSize+1) 1])];

    L_fg = L_(windows{i}.FgMask==1 & windows{1}.ShapeModel > fg_thresh);
    a_fg = a_(windows{i}.FgMask==1 & windows{1}.ShapeModel > fg_thresh);
    b_fg = b_(windows{i}.FgMask==1 & windows{1}.ShapeModel > fg_thresh);
    X_fg = [L_fg a_fg b_fg];
    X_fg2 = [X_fg; prevWindows{i}.X_fg];
    
    L_bg = L_(windows{i}.BgMask==1 & windows{1}.ShapeModel > bg_thresh);
    a_bg = a_(windows{i}.BgMask==1 & windows{1}.ShapeModel > bg_thresh);
    b_bg = b_(windows{i}.BgMask==1 & windows{1}.ShapeModel > bg_thresh);
    X_bg = [L_bg a_bg b_bg];
    X_bg2 = [X_bg; prevWindows{i}.X_bg];


%%
if(size(X_fg2, 1) > size(X_fg2, 2) && size(X_bg2, 1) > size(X_bg2, 2))
iter = 100;
converged = false;
while(converged == false)
iter = iter + 100;
options = statset('MaxIter',iter);
GMM_fg = fitgmdist(X_fg2,3,'RegularizationValue',0.1, 'Options', options);
GMM_bg = fitgmdist(X_bg2,3,'RegularizationValue',0.1, 'Options', options);
converged = GMM_bg.Converged && GMM_fg.Converged;
end


f = pdf(GMM_fg,K_);
b = pdf(GMM_bg,K_);
% 
f_ = reshape(f, [wSize+1 wSize+1]);
b_ = reshape(b, [wSize+1 wSize+1]);

fb = f_ ./ (f_ + b_);

if (numel(find(fb > .75)) < numel(find(windows{i}.ColorModel > .75))) 
    windows{i}.ColorModel = fb;
    windows{i}.ColorConfidence = updateColorConfidence(windows{i}, wSize);
    sprintf(['window ' num2str(i) ' updated'])
    windows{i}.X_fg = X_fg;
    windows{i}.X_bg = X_bg;
else
    window{i}.X_fg = prevWindows{i}.X_fg;
     window{i}.X_bg = prevWindows{i}.X_bg;
end
    sprintf([num2str(i) ' generated'])
else
     window{i}.X_bg = prevWindows{i}.X_fg;
      window{i}.X_bg = prevWindows{i}.X_bg;
end
end
outWindows = windows;


end

