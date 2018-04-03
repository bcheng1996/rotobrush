function [outWindows] = getColorConfidence(inWindows,wSize)
%GETCOLORCONFIDENCE Summary of this function goes here
%   Detailed explanation goes here
windows = inWindows;

for i=1:size(windows,2)
   
    bw = windows{i}.EdgeBoundary;
    [D IDX] = bwdist(bw);
    Wc = exp(-(D.^2)/((wSize+1)/2)^2);
    Lt = windows{1}.Fg;
    Pc = windows{1}.ColorModel;
    Fc_top = sum(sum(abs(Lt-Pc) .* Wc));
    Fc_bot = sum(sum(Wc));
    Fc = 1 - (Fc_top/Fc_bot);
    windows{i}.ColorConfidence = Fc;
 
end
outWindows = windows;

end

