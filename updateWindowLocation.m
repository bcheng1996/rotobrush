function [outWindows] = updateWindowLocation(inWindows,inImg, inFlow)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
windows = inWindows;
flow = inFlow;
new_windows = [];
%%

for i=1:size(windows,2)
    window = windows{i};
    X = window.Position(1)-15;
    Y = window.Position(2)-15;
    XX = X + 30;
    YY = Y + 30;
    Vx = flow.Vx(X:XX,Y:YY);
    Vy = flow.Vy(X:XX,Y:YY);

    avg_Vx = mean(mean(Vx));
    avg_Vy = mean(mean(Vy));
    sprintf(['avg' num2str(i) 'is' num2str(avg_Vx)])
    new_window = window;
    new_window.Position = [window.Position(1) + avg_Vx window.Position(2) + avg_Vy ];
    
    new_windows{i} = new_window;
end




outWindows = new_windows;

end

