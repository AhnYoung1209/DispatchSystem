% �����µ�ͼ����ʾ��
% hAxe=axes('Parent',gcf,... % �����µ�axe�� ��'parent' ��������Ϊ��ǰ����gcf
%     'Units','pixels',...  %���õ�λΪpixels
%     'Position',[30 80 1850 885]);  % ָ��axe��λ�ã���ʽΪ[left bottom width height]�� left��bottom�趨��axe������ %�����꣬width��height�趨�˴��ڵĿ�Ⱥ͸߶�

% h = figure;
% set(gcf,'outerposition',get(0,'screensize'));
% clf(h)
% imshow(TestController.MRegionMap, [])

imshow(ones(1, 1),'InitialMagnification','fit')   

% close all
% loc = [20 108];
% goal = [20 113];
% % loc = [55 373];
% % goal = [45 365];
% load city_map
% tic
% [path, directions] = astar_jw(city_map, fliplr(loc), fliplr(goal));
% toc
% figure, imshow(city_map), 
% axis([1 500 1 500])
% hold on
% plot(loc(1), loc(2), 'r*');
% plot(goal(1), goal(2), 'b*');
% plot(path(:, 2), path(:, 1), 'gs');


% load city_map
% coor = [9 57];
% 
% CenPosX = coor(1);
% CenPosY = coor(2);
% distance = 10;
% 
% if CenPosY - distance < 1
%    areaY = 1:CenPosY+distance;
% elseif CenPosY + distance > 500
%    areaY = CenPosY-distance:500;
% else
%    areaY = CenPosY-distance:CenPosY+distance;
% end
% 
% if CenPosX - distance < 1
%    areaX = 1:CenPosX+distance;
% elseif CenPosX + distance > 500
%    areaX = CenPosX-distance:500;
% else
%    areaX = CenPosX-distance:CenPosX+distance;
% end
% 
% [row,col] = find(city_map(areaY,areaX)==0);
% relaloc = randi([1,length(row)]);
% 
%     
% NextPosX = col(relaloc) + areaX(1) - 1;
% NextPosY = row(relaloc) + areaY(1) - 1;
% 
% 
% outputCoor = [ NextPosX NextPosY ];
% outputCoor
% city_map(outputCoor(2), outputCoor(1))
% figure,  imshow(city_map),  hold on;
% axis([1 500 1 500])
% plot(coor(1), coor(2), 'r*');
% plot(outputCoor(1), outputCoor(2), 'bs');
%  