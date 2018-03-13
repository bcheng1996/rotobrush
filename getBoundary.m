function [outWindows] = untitled(inWindows)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
windows = inWindows;
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
    windows{k}.BgMaskCord = XY2_update;
    
    windows{k}.FgMask = getMask(XY_update, wSize+1);
    windows{k}.BgMask = getMask(XY2_update, wSize+1);
   
end
outWindows = windows;
end

