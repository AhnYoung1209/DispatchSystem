classdef Driver < handle
    properties (SetAccess = {?Driver, ?Controller})
        status = 'invalid' % waiting         
        salary = 0
        cost = 0
        timeWaste = 0
        mileWaste = 0     
        coor = [-1 -1]
        target = [-1 -1] % -1 means random; 0 means stay
        ownPassenger
        path
        posPath = 0
        debug = 1
    end   
   
    properties (Dependent)
        satisfaction
    end
    
    properties (Transient)
        driverListener
    end
    
    events
        PassengerDepart
        PassengerArrive
    end
    
    methods
        function obj = Driver()
            if nargin == 0
            end
        end            
                
        function [] = listen(obj, ControllerInstance)
            obj.driverListener = ControllerInstance.adddriverlistener(obj);
        end
        
        function [] = plot(obj)
            if(strcmp(obj.status, 'invalid'))
            else
                set(groot,'CurrentFigure',100); % by definition (100)
                plot(obj.coor(1), obj.coor(2), 'rs')
            end
        end
                
        function [] = update_Manhattan_simple(obj)
            if(isequal(obj.coor, obj.target) || strcmp(obj.status, 'invalid'))
                return
            else
               obj.coor = obj.coor + sign(obj.target - obj.coor);
            end
        end
        
        function [] = update_Astar(obj)
            if(strcmp(obj.status, 'invalid'))
                return
            end
            obj.posPath = obj.posPath + 1;
            % the first point in path is the starting point (+1 is needed)
            obj.coor = [obj.path(obj.posPath+1, 2) obj.path(obj.posPath+1, 1)];
            if(strcmp(obj.status, 'busy'))
                if(obj.coor == obj.target)
                    notify(obj, 'PassengerDepart');
                end
            end
            if(strcmp(obj.status, 'talking'))
                if(obj.coor == obj.target)
                    notify(obj, 'PassengerArrive');
                end
            end
                    
        end
        
        function [] = pathplan(obj, map)    
            if(obj.debug)
                if(map(obj.coor(2), obj.coor(1)) || map(obj.target(2), obj.target(1)))
                    disp(obj)
                end
            end
            [tempPath, ~] = astar_jw(map, fliplr(obj.coor), fliplr(obj.target));
            obj.path = tempPath;
%             disp('Path planning completes');
            obj.posPath = 0;
        end
    end
        
        
end