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
    
    xCenter = [xCenter; B{1}(i,2)];
    yCenter = [yCenter; B{1}(i,1)];
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

% detect Fg Bg boundary
for k=1:size(windows,2)

    w_B = bwboundaries(windows{k}.Fg);
    w_B = w_B{1};
    w_B_edge = [];
    
    for i=1:size(w_B,1)
        if(w_B(i,1) ~= wSize+1 && w_B(i,2) ~= wSize+1 && w_B(i,1) ~= 1 && w_B(i,2) ~= 1)  
            w_B_edge = [w_B_edge ; w_B(i,:)]; 
        end
    end

    [X,Y] = find(windows{k}.Fg == 1);
    [X2, Y2] = find(windows{k}.Bg == 1);
    
    XY = [X  Y];
    XY2 = [X2 Y2];
    
    XY_update = [];
    XY2_update = [];
  
    %foreground mask
    for i=1:size(XY, 1)
        p1 = XY(i,:);
        p2 = [w_B_edge(:,1) w_B_edge(:,2)];  
        dist = pdist2(p2, p1, 'euclidean');
        if min(dist) > 5
        XY_update = [XY_update ; p1];
        end
    end

    windows{k}.FgMaskCord = XY_update;
    
    %background mask
    for i=1:size(XY2, 1)
        p1 = XY2(i,:);
        p2 = [w_B_edge(:,1) w_B_edge(:,2)];  
        dist = pdist2(p2, p1, 'euclidean');
        if min(dist) > 5
        XY2_update = [XY2_update; p1];
        end
    end
   
   
    
end

%% shows mask of first window 
imshow(windows{1}.Image);
hold on
plot(windows{1}.FgMaskCord(:,2), windows{1}.FgMaskCord(:,1), '.' , 'Color' , 'r');
hold off

%%
K = rgb2lab(windows{5}.Image);
L_ = K(:,:,1);
a_ = K(:,:,2);
b_ = K(:,:,3);

%I_ = mat2gray(windows{1}.Image);
K_ = [reshape(L_,[31*31 1]) reshape(a_,[31*31 1]) reshape(b_,[31*31 1])];

L_fg = L_(windows{5}.FgMask==1);
a_fg = a_(windows{5}.FgMask==1);
b_fg = b_(windows{5}.FgMask==1);
X_fg = [L_fg a_fg b_fg];

L_bg = L_(windows{5}.BgMask==1);
a_bg = a_(windows{5}.BgMask==1);
b_bg = b_(windows{5}.BgMask==1);
X_bg = [L_bg a_bg b_bg];






%%
options = statset('MaxIter',500);
GMM_fg = fitgmdist(X_fg,3,'RegularizationValue',0.1, 'Options', options);
GMM_bg = fitgmdist(X_bg,3,'RegularizationValue',0.1, 'Options', options);

f = cdf(GMM_fg,K_);
b = cdf(GMM_bg,K_);
% 
f_ = reshape(f, [wSize+1 wSize+1]);
b_ = reshape(b, [wSize+1 wSize+1]);

fb = f_ ./ (f_ + b_);

end
