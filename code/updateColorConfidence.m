function [CC] = updateColorConfidence(inWindow, wSize)
%UPDATECOLORCONFIDENE Summary of this function goes here
%   Detailed explanation goes here
%%
window = inWindow;
bw = window.EdgeBoundary;
[D IDX] = bwdist(bw);
Wc = exp(-(D.^2)/((wSize+1)/2)^2);
Lt = window.Fg;
Pc = window.ColorModel;
Fc_top = sum(sum(abs(Lt-Pc) .* Wc));
Fc_bot = sum(sum(Wc));
CC = 1 - (Fc_top/Fc_bot);

end

