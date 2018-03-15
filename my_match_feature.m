function [match] = my_match_feature(FD1,FD2)
%% Match feature points from 1 image to another given their respective feature descriptors.    
%  returns a 'match' matrix of N X 1 where N is the amount of feature
%  descriptors in FD1. Each row of 'match' corresponds to the index in descriptor 1 at
%  which a correspondance can be found, if the value at that row is not -1. 
%  The value at a row details what point the row index correspondes too. 

m1 = size(FD1,2);
match = zeros(m1, 1);

for i=1:size(FD1,2)
    desc = FD1(:,i);
    temp = FD2 - desc;
    temp = sum(temp.^2,1);
    [vals,idx] = sort(temp,'ascend');
     mm_1 = FD2(:,idx(1));
     mm_2 = FD2(:,idx(2));
     if sum((desc - mm_1).^2)/sum((desc - mm_2).^2) < 0.65
         match(i) = idx(1);
     else
         match(i) = -1;
     end
end
end