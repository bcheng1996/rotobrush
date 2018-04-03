function [outWindows] = combine(inWindows, wSize)
%MERGE Summary of this function goes here
%   Detailed explanation goes here
%%

windows = inWindows;

for i=1:size(windows,2)
    Fs = windows{i}.ShapeModel;
    Lt = windows{i}.FgMask;
    Pc = windows{i}.ColorModel;
    Pf = (Fs .* Lt) + ((1-Fs).*Pc); 
    windows{i}.FgMap = Pf;
end
outWindows = windows;

end


