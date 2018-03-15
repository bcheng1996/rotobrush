function [FD] = getFD(image,ANMS)
%% Generate File Descriptor for image given a ANMS corner distribution
%temp 

row = size(ANMS,1);
FD = [];

for i=1:row
    padImage = padarray(mat2gray(image),[20,20],'replicate');
    subImage = padImage(ANMS(i,2):ANMS(i,2)+39,ANMS(i,1):ANMS(i,1)+39);
    Gauss = fspecial('gaussian',[10,10], 2);
    filteredImage = imfilter(subImage,Gauss);
    subSample = filteredImage(1:5:end, 1:5:end);
    subSample = reshape(subSample,[64,1]);
    FD_col =  (double(subSample) - mean(double(subSample))) / std(double(subSample)); 
    FD = [FD FD_col];
end
    
end