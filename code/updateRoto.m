function [mask,img,outWindows] = updateRoto(inWindows,wSize,image1,image2,mask)
%UPDATEROTO Summary of this function goes here
%   Detailed explanation goes here

img1 = image1;
img2 = image2;
windows = inWindows;
%%
%%temp
%img1 = imageSet{2};
%img2 = imageSet{3};
%wSize = 30;

%% Detect Transformation
temp_img = rgb2gray(img1);
temp_img(mask==0) = NaN;
temp_img2 = rgb2gray(img2);
pts1 = detectSURFFeatures(temp_img,'MetricThreshold',200);
pts2 = detectSURFFeatures(temp_img2,'MetricThreshold',200);
[ft1,vpoints1] = extractFeatures(rgb2gray(img1), pts1);
[ft2,vpoints2] = extractFeatures(rgb2gray(img2),pts2);

%% Show detected points
%imshow(img1);
hold on
%plot(pts1.Location(:,1),pts1.Location(:,2),'.', 'Color', 'r');
hold off

idxpair = matchFeatures(ft1,ft2);
matchedPoints1 = vpoints1(idxpair(:, 1), :);
matchedPoints2 = vpoints2(idxpair(:, 2), :);

%myShowMatch(img1,img2, matchedPoints1,matchedPoints2,'montage');
%% Estimage Geometric Transform
tform = estimateGeometricTransform(matchedPoints1.Location, ...
    matchedPoints2.Location, 'affine');

rout = imref2d(size(img2));
out = imwarp(img1,tform,'OutputView', rout);
out_mask = imwarp(mask, tform,'OutputView', rout);
opticFlow = opticalFlowFarneback('FilterSize', 5);
flow = estimateFlow(opticFlow, rgb2gray(out));
imshow(out)
hold on
plot(flow);
hold off
flow = estimateFlow(opticFlow, rgb2gray(img2));
imshow(img1)
hold on
quiver(flow.Vx, flow.Vy)
for i=1:size(windows,2)
    %plot the windows
    pos = windows{i}.Position;
    w = rectangle('Position', [pos(1) - (wSize/2), pos(2) - (wSize/2) wSize wSize],'EdgeColor', 'y');
    plot(pos(1), pos(2),'.','Color', 'r');
end
hold off
out_windows = updateWindowLocation(windows,out,flow,out_mask,wSize,tform);


%% Show the updated windows
imshow(img2);

hold on
quiver(flow.Vx, flow.Vy)
for i=1:size(out_windows,2)
    %plot the windows
    pos = out_windows{i}.Position;
    w = rectangle('Position', [pos(1) - (wSize/2), pos(2) - (wSize/2) wSize wSize],'EdgeColor', 'y');
    plot(pos(1), pos(2),'.','Color', 'r');
end

hold off


%% Update Color Model
% update boundary first
for i=1:3
out_windows = updateBoundary(out_windows,out_mask,wSize);
out_windows = getShapeModel(out_windows, wSize);    
out_windows = updateColorModel(out_windows,inWindows,wSize);


%% Combine Shape and Color Model
[out_windows] = combine(out_windows, wSize);
%%
[maskOut, outImg] = merge(out_windows, wSize, image2,out_mask);
out_mask = maskOut;
img = outImg;
end
mask = out_mask;
outWindows = out_windows;
end

