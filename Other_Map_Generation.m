% The most simple version of how to generate a map
close all; clear
mapSize = 50;
numRoad = mapSize / 2;
map = zeros(mapSize,mapSize);
line = randi([1,mapSize],1,numRoad);
column = randi([1,mapSize],1,numRoad);
map(line,:) = 1;
map(:,column) = 1;

% we want 1->0 and 0->1
map = 1 - map;
city_map = map; % just name
% imshow command is modified with parameters for better viewing experience
figure, imshow(map,'InitialMagnification','fit')