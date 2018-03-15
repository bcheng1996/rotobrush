function [roto] = rotobrush(imageSet)
%Takes an imageSet that contains frames of a video and returns a rotoscoped
%version of each frame;

%%
img1 = imageSet{1};

%% Create mask around object on frame 1
BW_img1 = roipoly(img1);

%% Create Local Windows
B = bwboundaries(BW_img1);
wSize = 30;
t = wSize/2;
windows = {};
xCenter = [];
yCenter = [];

imshow(img1);
hold on
for i=1:+20:size(B{1},1)
    %plot the windows
    w = rectangle('Position', [B{1}(i,2) - wSize/2, B{1}(i,1) - wSize/2 wSize wSize],'EdgeColor', 'y');
    plot(B{1}(i,2), B{1}(i,1),'.','Color', 'r');
    
    %initialize a new window struct
    window = struct;
    
    xCenter =  B{1}(i,2);
    yCenter =  B{1}(i,1);
    window.Position = [xCenter yCenter];
    
    im = (img1(B{1}(i,1)-t:B{1}(i,1)+t,B{1}(i,2)-t:B{1}(i,2)+t,:));
    window.Image = im;
    
    F = zeros([31 31]);
    F = BW_img1(B{1}(i,1)-t:B{1}(i,1)+t,B{1}(i,2)-t:B{1}(i,2)+t) == 1;
    Bg = (F ~= 1);
    window.Fg = F;
    window.Bg = Bg;
    
    windows{end+1} = window;
end
hold off


%% Initialize Boundaries 
windows = getBoundary(windows,wSize);

%% shows mask of first window 
i = 15;
imshow(windows{i}.Image);
hold on
plot(windows{i}.FgMaskCord(:,2), windows{i}.FgMaskCord(:,1), '.' , 'Color' , 'r');
plot(windows{i}.BgMaskCord(:,2), windows{i}.BgMaskCord(:,1), '.' , 'Color' , 'b');
hold off

%% Initialize Color and Shape Model

windows = getColorModel(windows, wSize);

%Get Color Confidence
windows = getColorConfidence(windows,wSize);

windows = getShapeModel(windows, wSize);

%% Detect Transformation
pts1 = detectSURFFeatures(rgb2gray(img1),'MetricThreshold',200);
pts2 = detectSURFFeatures(rgb2gray(imageSet{2}),'MetricThreshold',200);
[ft1,vpoints1] = extractFeatures(rgb2gray(img1), pts1);
[ft2,vpoints2] = extractFeatures(rgb2gray(imageSet{2}),pts2);

%% Show detected points
imshow(img1);
hold on
plot(pts1.Location(:,1),pts1.Location(:,2),'.', 'Color', 'r');
hold off

idxpair = matchFeatures(ft1,ft2);
matchedPoints1 = vpoints1(idxpair(:, 1), :);
matchedPoints2 = vpoints2(idxpair(:, 2), :);

myShowMatch(img1,imageSet{2}, matchedPoints1,matchedPoints2,'montage');
%% Estimage Geometric Transform
tform = estimateGeometricTransform(matchedPoints1.Location, ...
    matchedPoints2.Location, 'affine');

out = imwarp(img1,tform);

opticFlow = opticalFlowHS();
flow = estimateFlow(opticFlow, rgb2gray(out));

out_windows = updateWindowLocation(windows,out,flow);
%%
corner1 = cornermetric(rgb2gray(img1));
corner2 = cornermetric(rgb2gray(imageSet{2}));

N_best = 200;

[X Y] = apply_anms(corner1,N_best);
 X = cell2mat(reshape(X,[N_best,1]));
 Y = cell2mat(reshape(Y,[N_best,1]));
 XY = cat(3,X,Y);
 
[X Y] = apply_anms(corner2,N_best);
 X = cell2mat(reshape(X,[N_best,1]));
 Y = cell2mat(reshape(Y,[N_best,1]));
 XY2 = cat(3,X,Y);
 
 ANMSset = {};
 ANMSset{1} = XY;
 ANMSset{2} = XY2;
 
%%

imshow(img1);
hold on
X = ANMSset{1}(:,1);
Y = ANMSset{1}(:,2);
plot(X,Y,'.', 'Color','r');
hold off

FD = getFD(img1,XY);
FD2 = getFD(imageSet{2},XY2);

%% Match features using the respective feature descriptors
sprintf('matching features')
%middle = ceil(numSets/2);
x_matches = [];
y_matches = [];

match = my_match_feature(FD,FD2);
% seperate nx2 matrix in the ANMSset to respective X and Y vectors
x_cor = ANMSset{1}(:,:,1);
y_cor = ANMSset{1}(:,:,2);
xx_cor = ANMSset{2}(:,:,1);
yy_cor = ANMSset{2}(:,:,2);
% calcuate the matching points where x1 -> x2 and y1 -> y2 
x1 = x_cor(match~=-1);
y1 = y_cor(match~=-1);
x2 = xx_cor(match(match~=-1));
y2 = yy_cor(match(match~=-1));
x_matches{1} = [x1 x2];
y_matches{2} = [y1 y2];

%show match of second last and last image
myShowMatch(imageSet{end-1},imageSet{end},[x1 y1],[x2 y2],'montage');
%%
tform = estimateGeometricTransform([x1 y1],[x2 y2],'similarity');


end

