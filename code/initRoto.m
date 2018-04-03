function [outWindows] = initRoto(image1, image2, roipoly,inwSize,window_int)
%Takes an imageSet that contains frames of a video and returns a rotoscoped
%version of each frame;

%%
img1 = image1;
img2 = image2;
BW_img1 = roipoly;

%% Create Local Windows
B = bwboundaries(BW_img1);
wSize = inwSize;
t = wSize/2;
windows = {};
xCenter = [];
yCenter = [];

imshow(img1);
hold on
for i=1:+window_int:size(B{1},1)
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
    
    F = zeros([wSize+1 wSize+1]);
    F = BW_img1(B{1}(i,1)-t:B{1}(i,1)+t,B{1}(i,2)-t:B{1}(i,2)+t) == 1;
    Bg = (F ~= 1);
    window.Fg = F;
    window.Bg = Bg;
    
    windows{end+1} = window;
end
hold off


%% Initialize Boundaries 
windows = getBoundary(windows,wSize);


%% Initialize Color and Shape Model

windows = getColorModel(windows, wSize);
%%
%Get Color Confidence
windows = getColorConfidence(windows,wSize);

windows = getShapeModel(windows, wSize);
%% 
outWindows = windows;
end

