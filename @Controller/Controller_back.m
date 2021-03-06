classdef Controller_back < handle
    properties (SetAccess = private)
        version = '1.0'
        APassenger % Array of passenger
        ADriver % Array of driver
        MRegion % Matrix (2 dimensional) of region
        MRegionMap
        numPassenger = 0
        numDriver = 0        
        hMain
    end
    
    properties (SetAccess = public)
        maxNumPassenger = 500
        maxNumDriver = 250
        dimRegion1 = 500
        dimRegion2 = 500
        booDebug = 0;
        
        disDriverRandom = 10;
        disPassengerTarget = 50;
    end
    
    methods
        
        function obj = Controller()
            obj.initialization
        end
        
        function [] = initialization(obj)
            obj.APassenger = Passenger();
            obj.APassenger(obj.maxNumPassenger) = Passenger();
            for i = 1:1:obj.maxNumPassenger
                listen(obj.APassenger(i), obj);
            end
            obj.ADriver = Driver();
            obj.ADriver(obj.maxNumDriver) = Driver();
            for i = 1:1:obj.maxNumDriver
                listen(obj.ADriver(i), obj);
            end            
            obj.MRegion = Region(); 
            obj.MRegion(obj.dimRegion1, obj.dimRegion2) = obj.MRegion();
            load city_map;
            obj.MRegionMap = city_map;      
            obj.hMain = figure;              
            drawnow;
            disp('Please set the timer now');
            disp('Generating drivers');
            driverinitialization(obj);            
        end
        
        function lh = settimer(obj, TimerInstance)
            lh = addlistener(TimerInstance, 'TimeRefresh', ...
             @(src, event)obj.jump(src, event));
            disp('Timer is set, state machine begins to work');
        end  
        
        function lp = addpassengerlistener(obj, passenger)
            lp = addlistener(passenger, 'DriverRequest', ...
             @(src, event)obj.requesthandle(src, event));           
        end
        
        function [lf1, lf2] = adddriverlistener(obj, driver)
            lf1 = addlistener(driver, 'PassengerDepart', ...
             @(src, event)obj.departhandle(src, event));     
            lf2 = addlistener(driver, 'PassengerArrive', ...
             @(src, event)obj.arrivehandle(src, event));
        end        
        
        function [] = requesthandle(obj, src, ~)    
            driverIndex = finddriver(obj, src);
            commanddriverafterselected(obj.ADriver(driverIndex), src, ...
                obj.MRegionMap);
        end
        
        function [] = departhandle(obj, src, ~)
            % target has been set in the driver's method
            src.status = 'talking';
            src.target = src.ownPassenger.target;            
            src.pathplan(obj.MRegionMap);
            src.ownPassenger.status = 'talking';
        end
        
        function [] = arrivehandle(~, src, ~)
            src.status = 'valid';
            src.ownPassenger.status = 'invalid';
            src.posPath = 0;
            src.path = [];
        end
        
        % jump is the core function of controller
        % jump is executed every time the timer is updated (with event
        % called TimeRefresh)
        function [] = jump(obj, src, ~) % src and eventData
            if(~mod(src.time - 1, 50))
                obj.generatepassenger 
            end
            % obj.setdrivertarget % drivers whos are not requested
            % now included in the updatedriver function
            obj.updatedriver % drivers move torward target
            obj.objplot;
        end
            
        function dispversion(obj, ~, ~)            
            disp(['This is controller with vrsion : ', obj.version]);   
            disp('Presented for the course of system engineering');
        end
        
        function [] = generatepassenger(obj)
            % row is Y(in graph)
            logic = calclogicfromregion(obj);
            if(obj.booDebug); figure, imshow(flipud(logic));end
            logic = logic .* (obj.MRegionMap == 0);
            [X, Y] = find(logic == 1);
            if(isempty(X) || isempty(Y))
                disp('Nothing is generated');
                return
            end
            count = 0;
            for i = 1:1:obj.maxNumPassenger
                if(i == 501)
                    error('Space is drained (pw)');
                end
                if(strcmp(obj.APassenger(i).status, 'invalid'))
                    count = count + 1;
                    obj.numPassenger = obj.numPassenger + 1;
                    obj.APassenger(i).coor = [Y(count), X(count)];
                    obj.APassenger(i).status = 'waiting';
                    % think of a target
                    obj.APassenger(i).target = targetset(obj.MRegionMap, obj.APassenger(i).coor, ...
                        obj.disPassengerTarget);
                    % and request for a car
                    obj.APassenger(i).driverrequest
                end
                if(count == length(X))
                    break;
                end
            end
        end
        
        function [] = updatedriver(obj)
            obj.setdrivertarget; % only has effect on these without request.
            count = 0;
            for i = 1:1:obj.maxNumDriver
                if(strcmp(obj.ADriver(i).status, 'invalid'))
                    continue
                else                
                count = count + 1;
                obj.ADriver(i).update_Astar();
                if(count == obj.numDriver)
                    break
                end
                end
            end            
        end
        
        function [] = updatedriver_vector(obj)
            % still not working
            update_Astar(obj.ADriver);
        end
        
        
        function [] = setdrivertarget(obj)
            % and path planning
            count = 0;
            for i = 1:1:obj.maxNumDriver
                if(strcmp(obj.ADriver(i).status, 'invalid'))
                    continue
                else
                    count = count + 1;    
                    if(~strcmp(obj.ADriver(i).status, 'valid'))
                        continue
                    else
                        if(obj.ADriver(i).target == obj.ADriver(i).coor)
                            obj.ADriver(i).target = targetset(obj.MRegionMap, obj.ADriver(i).coor, ...
                                obj.disDriverRandom); % 10 is the distance
                        end
                        % path planning is not used in update_Manhattan method
                        obj.ADriver(i).pathplan(obj.MRegionMap);
                    end
                end
                if(count == obj.numDriver)
                    break
                end
            end
                
        end
        
        function [] = objplot(obj) % need improvement over invalid
            clf(obj.hMain);
            % must be enabled if multi plot is needed
            set(groot,'CurrentFigure',obj.hMain); 
            j = get(gcf,'javaframe');
            set(j,'maximized',true);
            imshow(obj.MRegionMap,'InitialMagnification','fit');    
            hold on        
            count = [0 0];
            for i = 1:1:obj.maxNumPassenger
                if(strcmp(obj.APassenger(i).status, 'invalid'))
                    continue
                else
                    count(1) = count(1) + 1;
                    if(strcmp(obj.APassenger(i).status, 'talking'))
                        continue
                    else
                    plot(obj.APassenger(i).coor(1), obj.APassenger(i).coor(2), 'b*'); 
                    end
                    if(count(1) == obj.numPassenger); break; end
                end                    
            end

            for i = 1:1:obj.maxNumDriver
                if(strcmp(obj.ADriver(i).status, 'invalid'))
                    continue
                else
                    count(2) = count(2) + 1;
                    if(strcmp(obj.ADriver(i).status, 'talking'))
                        plot(obj.ADriver(i).coor(1), obj.ADriver(i).coor(2), 'ms'); 
                    else
                        plot(obj.ADriver(i).coor(1), obj.ADriver(i).coor(2), 'rs'); 
                    end
                    plot(obj.ADriver(i).target(1), obj.ADriver(i).target(2), 'gv');                     
                    if(count(2) == obj.numDriver); break; end   
                end
            end
            % code below is optional (display target)
            drawnow;      
        end
        
    end
end

function driverIndex = finddriver(obj, Passenger)
    driverDis = (obj.dimRegion1 * 2 + 1) * ones(obj.numDriver, 2);
    count = 0;
    for i = 1:1:obj.maxNumDriver
        if(strcmp(obj.ADriver(i).status, 'invalid'))
            continue
        else
            count = count + 1;
            if(~strcmp(obj.ADriver(i).status, 'valid'))
                continue
            else
                driverDis(count, 1) = mdist(obj.ADriver(i), Passenger);
                driverDis(count, 2) = i;
            end
        end
    end
    [~, index] = min(driverDis(:, 1));
    driverIndex = driverDis(index, 2);
end

function [] = commanddriverafterselected(Dri, Pas, map)
    Dri.status = 'busy';
    Dri.target = Pas.coor;
    % path planning
    Dri.pathplan(map);
    Dri.ownPassenger = Pas;
end

function distance = mdist(Dri, Pas)
    coor1 = Dri.coor;
    coor2 = Pas.coor;
    distance = abs(coor1(1) - coor2(1)) + abs(coor1(2) - coor2(2));
end

function logic = calclogicfromregion(obj)   
    % extremely simplified version
    numPassengerExpect = 50;
    numPoint = obj.dimRegion1 .* obj.dimRegion2;
    numP = numPassengerExpect / numPoint;    
    logic = randsrc(obj.dimRegion1, obj.dimRegion2, [[0 1];[1- numP numP]]);
end

function [] = driverinitialization(obj)
    numDriverExpect = 200;
    numPoint = obj.dimRegion1 .* obj.dimRegion2;
    numP = numDriverExpect / numPoint;
    logic = randsrc(obj.dimRegion1, obj.dimRegion2, [[0 1];[1- numP numP]]);
    logic = logic .* (obj.MRegionMap == 0);
    [X, Y] = find(logic == 1);
    if(isempty(X) || isempty(Y))
        disp('Nothing is generated');
        return
    end    
    for i = 1:1:length(X)
        if(length(X) > obj.maxNumDriver)
            error('Space is drained (pw)');
        end
        obj.numDriver = obj.numDriver + 1;
        obj.ADriver(i).coor = [Y(i), X(i)];
        obj.ADriver(i).target = obj.ADriver(i).coor;
        obj.ADriver(i).status = 'valid';
    end    
end

function outputCoor = targetset(city_map, coor, distance)
    sizeMap = size(city_map, 1);
    if(nargin == 2)
        distance = 10;
    end
    CenPosX = coor(1);
    CenPosY = coor(2);
    if CenPosY - distance < 1
       areaY = 1:CenPosY+distance;
    elseif CenPosY + distance > sizeMap
       areaY = CenPosY-distance:sizeMap;
    else
       areaY = CenPosY-distance:CenPosY+distance;
    end

    if CenPosX - distance < 1
       areaX = 1:CenPosX+distance;
    elseif CenPosX + distance > sizeMap
       areaX = CenPosX-distance:sizeMap;
    else
       areaX = CenPosX-distance:CenPosX+distance;
    end
    [row,col] = find(city_map(areaY,areaX)==0);
    relaloc = randi([1,length(row)]);    
    NextPosX = col(relaloc) + areaX(1) - 1;
    NextPosY = row(relaloc) + areaY(1) - 1;
    
    while(isequal([NextPosX,NextPosY],[CenPosX,CenPosY]))
        relaloc = randi([1,length(row)]);
        NextPosX = col(relaloc) + areaX(1) - 1;
        NextPosY = row(relaloc) + areaY(1) - 1;
    end

    
    outputCoor = [NextPosX NextPosY];
end