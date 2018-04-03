function [outWindows] = updateBoundary(inWindows,mask,wSize)
%UPDATEBOUNDARY Summary of this function goes here
%   Detailed explanation goes here
t = wSize/2;
windows = inWindows;
for i=1:numel(windows)
    Fg = zeros([wSize wSize]);
    pos = inWindows{i}.Position;
    X = round(pos(1));
    Y = round(pos(2));
    Fg = mask(Y-t:Y+t, X-t:X+t);
    inWindows{i}.Fg = Fg;
end
windows = getBoundary(inWindows,wSize);
outWindows = windows;
end

