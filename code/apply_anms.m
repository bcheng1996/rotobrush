function [X,Y] = apply_anms(Cimg, Nbest)
%APPLY_ANMS Summary of this function goes here
%   Detailed explanation goes here

%% find all local maxima 
MAX = 999999999;
N_StrongSet = {};
N_StrongSet{end+1} = imregionalmax(Cimg);
R=[];
res=[];

[y,x] = find(N_StrongSet{1} == 1);
N_Strong = size(x,1);

for i=1:N_Strong
    R{end+1}=MAX;
end


for i=1:N_Strong
     ED = MAX;
    for j=1:N_Strong
       if(Cimg(y(j),x(j)) > Cimg(y(i),x(i)))
           ED = ((x(j)-x(i)).^2) + ((y(j)-y(i)).^2);
       end
       if(ED < R{i})
           R{i} = ED;
       end
    end
end

R_sorted = sort(cell2mat(R),2,'descend');

%%
X = [];
Y = [];
for i=1:Nbest
    [temp, temp_y] = find(cell2mat(R) == R_sorted(i));
    X {end+1} = x(temp_y);
    Y {end+1} = y(temp_y);
end

end