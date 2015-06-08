classdef Passenger < handle
    properties (SetAccess = {?Passenger, ?Controller})
        id
        status = 'invalid' % waiting 
        coor = [-1 -1]
        timeWait = 0 
        timeThreshold = 20;
        cost = 0
        target = [-1 -1]
        ownDriver
    end
    properties (Transient)
        passengerListener
    end    
    
    properties (Dependent)
        satisfaction
    end
    
    events
        DriverRequest
        GiveUp
    end
    
    methods
        function obj = Passenger()
            if nargin == 0
            end
        end
        
        function [] = erase(obj)
            obj.status = 'invalid';
            obj.timeWait = 0;
            obj.cost = 0;
            obj.coor = [-1 -1];
            obj.target = [-1 -1];
            obj.ownDriver = [];
        end
        
        function [] = giveup(obj)
            notify(obj, 'GiveUp');
            obj.erase();
        end
        
        function [] = listen(obj, ControllerInstance)
            obj.passengerListener = ControllerInstance.addpassengerlistener(obj);
        end
        
        function [] = driverrequest(obj)
            if(obj.timeWait >= obj.timeThreshold ||~strcmp(obj.status, 'waiting'))
                return
            else
                notify(obj, 'DriverRequest');
            end
        end
        
        function [] = wait(obj)
            obj.timeWait = obj.timeWait + 1;
            if(obj.timeWait >= obj.timeThreshold)
                obj.giveup;
            end
        end
        
        function [] = plot(obj)
            if(strcmp(obj.status, 'invalid'))
            else
                set(groot,'CurrentFigure',100); % by definition (100)
                plot(obj.coor(1), obj.coor(2), 'b*')
            end
        end
    end
        
        
end