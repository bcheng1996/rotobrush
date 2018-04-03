%------------- INPUT FRAME SET HERE ------------

frameSet = 'Frames5';

%-----------------------------------------------

%% Retrieving image set 
file_location = [cd '/..' '/input/'];
file_location = fullfile(file_location, frameSet);
filepattern = fullfile(file_location, '*.jpg');
numImages = length(dir(filepattern));

imageSet=[];

for i = 1:numImages
    imageSet{i} = imread(fullfile(file_location, [num2str(i) '.jpg']));
end
%%
rpoly = roipoly(imageSet{1});
%%
[windows] = initRoto(imageSet{1},imageSet{2},rpoly,50,20);
initWindows = windows;

%%
maskSet = {};
resSet = {};
windowSet = {};
mask = rpoly;
wSize = 50;
windows = initWindows;
%%

for i=1:10
    [mask,outImg,windows] = updateRoto(windows,wSize,imageSet{i},imageSet{i+1},mask);
    maskSet{i} = mask;
    resSet{i} = outImg;
    windowSet{i} = windows;
     sprintf(['frame ' num2str(i) ' generated'])
     imshow(resSet{1})
end

%%
k = 10;

imshow(resSet{k});

%% Save to output folder
file_location = cd;
file_location = fullfile(file_location, '/../output/');
for n=1:numel(resSet)
    fname = fullfile(file_location, [frameSet '_' num2str(n)]);
    B = bwboundaries(maskSet{n});
    max = 0;
    max_i = 0;

    for i=1:numel(B)
        if(size(B{i},1) > max)
        max = size(B{i},1);
        max_i = i;
        end
    end

X = B{max_i}(:,2);
Y = B{max_i}(:,1);
imshow(imageSet{n+1});
hold on
plot(X, Y,'-r');
hold off
    saveas(gcf, fname, 'jpg');
end



%% testing area

%plot windows
k = 3;

imshow(imageSet{k+1})
hold on
%for i=1:size(windowSet{k},2)
    %plot the windows
    pos = windowSet{k}{10}.Position;
    w = rectangle('Position', [pos(1) - wSize/2, pos(2) - wSize/2 wSize wSize],'EdgeColor', 'y');
    plot(pos(1), pos(2),'.','Color', 'r');
%end
hold off


%%
k = 11;
for i=1:10
   test_window = windowSet{i};
   hold on
   subplot(2,5,i)
   imshow(test_window{k}.Image);
   
   hold off
end





%%

L = superpixels(imageSet{1},500);

dist = bwdist(maskSet{1});
fg = find(dist == 0);
bg = find(dist > 1);


BW = lazysnapping(imageSet{1},L,fg,bg);
%%

n = 5;
 B = bwboundaries(maskSet{n});
    max = 0;
    max_i = 0;

    for i=1:numel(B)
        if(size(B{i},1) > max)
        max = size(B{i},1);
        max_i = i;
        end
    end

X = B{max_i}(:,2);
Y = B{max_i}(:,1);
imshow(imageSet{n+1});
hold on
plot(X, Y,'-r');
hold off


