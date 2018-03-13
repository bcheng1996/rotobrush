function [mask] = getMask(cord,wSize)
%GETMASK Summary of this function goes here
%   Detailed explanation goes here
%%
res = zeros([wSize wSize]);

for i=1:size(cord,1)
    res(cord(i,1),cord(i,2)) = 1;
end

mask = res;

end

