classdef Driver < handle
    properties (SetAccess = {?Driver, ?Controller})
        id
        status = 'invalid' % waiting
        numTaskDone = 0
        timeWork = 0
        mile = 0        
        mileSalary = 0
        mileWaste = 0     
        coor = [-1 -1] % same as below
        target = [-1 -1] % -1 means random; 0 means stay
        leaveRate = 0.01
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
        LeaveWork
    end
    
    methods
        function obj = Driver()
            if nargin == 0
            end
        end            
        
        function [] = returnvalid(obj)
            obj.posPath = 0;
            obj.path = [];
            obj.status = 'valid';
            obj.ownPassenger = [];
            obj.target = obj.coor;
        end
        
        function [] = returninvalid(obj)
            obj.returnvalid;
            obj.coor = [-1 -1];
            obj.target = [-1 -1];
            obj.status = 'invalid';
            obj.numTaskDone = 0;
            obj.timeWork = 0;
            obj.mile = 0;        
            obj.mileSalary = 0;
            obj.mileWaste = 0;                 
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
            
            if(strcmp(obj.status, 'valid'))
                booLeave = randsrc(1,1,[0 1;(1-obj.leaveRate) obj.leaveRate]);
                if(booLeave)
                    notify(obj, 'LeaveWork');
                    return
                end
            end           
            
            obj.posPath = obj.posPath + 1;
            if(obj.posPath == size(obj.path, 1))
                obj.posPath = obj.posPath - 1;
            end
            % the first point in path is the starting point (+1 is needed)
            obj.coor = [obj.path(obj.posPath+1, 2) obj.path(obj.posPath+1, 1)];
            
            switch(obj.status)
                case('valid')
                    obj.mile = obj.mile + 1;
                    obj.timeWork = obj.timeWork + 1;
                    obj.mileWaste = obj.mileWaste + 1;
                case('busy')
                    obj.mile = obj.mile + 1;
                    obj.timeWork = obj.timeWork + 1;                    
                case('talking')
                    obj.mile = obj.mile + 1;
                    obj.timeWork = obj.timeWork + 1;
                    obj.mileSalary = obj.mileSalary + 1;
            end   
            
            if(strcmp(obj.status, 'busy'))
                if(obj.coor == obj.target)
                    notify(obj, 'PassengerDepart');
                end
            end
            if(strcmp(obj.status, 'talking'))
                if(obj.coor == obj.target)
                    notify(obj, 'PassengerArrive');
                end
                obj.numTaskDone = obj.numTaskDone + 1;
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