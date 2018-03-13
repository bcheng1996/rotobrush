%------------- INPUT FRAME SET HERE ------------

frameSet = 'Frames1';

%-----------------------------------------------

%% Retrieving image set 
file_location = cd;
file_location = fullfile(file_location, frameSet);
filepattern = fullfile(file_location, '*.jpg');
numImages = length(dir(filepattern));

imageSet=[];

for i = 1:numImages
    imageSet{i} = imread(fullfile(file_location, [num2str(i) '.jpg']));
end

roto = rotobrush(imageSet);