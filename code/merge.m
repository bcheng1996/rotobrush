function [mask,image] = merge(inWindows,wSize,image,inMask)
%MERGE Summary of this function goes here
%   Detailed explanation goes here
%%
[im_x im_y] = size(rgb2gray(image));
temp_windows = inWindows;
center = zeros(wSize+1,wSize+1);
center(wSize/2, wSize/2) = 1;
center = bwdist(center);
eps = 0.1;

min_X = 100000;
min_Y = 100000;
max_X = 0;
max_Y = 0;

%find min-max X and Y cords.
for i=1:numel(temp_windows)
    pos = round(temp_windows{i}.Position);
    X = pos(1);
    Y = pos(2);
    min_X = min(X, min_X);
    min_Y = min(Y, min_Y);
    max_X = max(X, max_X);
    max_Y = max(Y, max_Y);
end

canvasF = zeros(size(rgb2gray(image)));
canvasSet = {};

for i=1:numel(temp_windows)
    canvas = zeros(size(rgb2gray(image)));
    pos = round(temp_windows{i}.Position);
    X = pos(1) - wSize/2;
    Y = pos(2) - wSize/2;
    P = temp_windows{i}.FgMap;
    dist = (center + eps).^-1;
    canvas(Y:Y+wSize,X:X+wSize) = (P.*dist)./dist;
    canvasSet{i} = canvas;
end


for i = 1:numel(canvasSet)
   canvasF = canvasF + canvasSet{i}; 
end

grayMask = mat2gray(inMask);
t = wSize/2;
for i=1:numel(inWindows)
   pos = inWindows{i}.Position;
   X = round(pos(1));
   Y = round(pos(2));
   grayMask(Y-t:Y+t,X-t:X+t) = 0;      
end

canvasF(isnan(canvasF)) = 0;
canvasF = canvasF + grayMask;
fmask = canvasF > .7;
R = image(:,:,1);
G = image(:,:,2);
B = image(:,:,3);

R(fmask == 0) = 0;
G(fmask == 0) = 0;
B(fmask == 0) = 0;

final = cat(3,G,B);
final = cat(3,R,final);

mask = fmask;
image = final;


end

