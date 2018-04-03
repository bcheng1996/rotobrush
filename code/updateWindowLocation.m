function [outWindows] = updateWindowLocation(inWindows,inImg, inFlow,mask,wSize,tform)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
windows = inWindows;
flow = inFlow;

%%
 for i=1:numel(windows)
     pos = transformPointsForward(tform,[windows{i}.Position]);
     windows{i}.Position = [pos(1),pos(2)];
 end

%% test transform forward


imshow(inImg)
hold on
for i=1:numel(windows)    %plot the windows
    pos = windows{i}.Position;
    w = rectangle('Position', [pos(1) - wSize/2, pos(2) - wSize/2 wSize wSize],'EdgeColor', 'y');
    plot(pos(1), pos(2),'.','Color', 'r');
end
hold off



for i=1:size(windows,2)
    window = windows{i};
    X = ceil(window.Position(1)-(wSize/2));
    Y = ceil(window.Position(2)-(wSize/2));
    XX = X + wSize;
    YY = Y + wSize;
    Vx = flow.Vx;
    Vy = flow.Vy; 
    Vx = Vx(Y:YY,X:XX);
    Vx(window.BgMask == 1) = NaN;
   
    Vy = Vy(Y:YY,X:XX);
    Vy(window.BgMask == 1) = NaN;
   
    %avg_Vx = ceil(sum(sum(Vx)));
    %avg_Vy = ceil(sum(sum(Vy)));
    avg_Vx = (mean(mean(Vx,2,'omitnan'),1,'omitnan'));
    avg_Vy = (mean(mean(Vy,2,'omitnan'),1,'omitnan'));
    if(isnan(avg_Vx))
        avg_Vx = 0;
    end
    if(isnan(avg_Vy))
        avg_Vy = 0;
    end
    sprintf(['avg' num2str(i) 'is: ' num2str(avg_Vy)])
    
    window.Position = [(window.Position(1) + avg_Vx) ...
        (window.Position(2) + avg_Vy)]; 
    windows{i}.Position = window.Position;
end

%updating image within window
t = wSize/2;
for i=1:numel(windows)
   pos = windows{i}.Position; 
   X = round(pos(1));
   Y = round(pos(2));
   new_img = inImg(Y-t:Y+t,X-t:X+t,:);
   windows{i}.Image = new_img;
   
    F = zeros([wSize+1 wSize+1]);
    F = mask(Y-t:Y+t,X-t:X+t) == 1;
    Bg = (F ~= 1);
    windows{i}.Fg = F;
    windows{i}.Bg = Bg;

end

%updating boundary
for k=1:size(windows,2)
    w_B = bwboundaries(windows{k}.Fg);
    w_B = cell2mat(w_B);
    w_B_edge = [];
    
    for i=1:size(w_B,1)
        if(w_B(i,1) ~= wSize+1 && w_B(i,2) ~= wSize+1 && w_B(i,1) ~= 1 && w_B(i,2) ~= 1)  
            w_B_edge = [w_B_edge ; w_B(i,:)]; 
        end
    end
    
    edge = zeros([wSize+1 wSize+1]);
    for i=1:size(w_B_edge)
        edge(w_B_edge(i,1),w_B_edge(i,2)) = 1;
    end

    windows{k}.EdgeBoundary = edge;
end

outWindows = windows;

end

