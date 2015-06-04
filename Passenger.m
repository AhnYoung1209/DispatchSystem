classdef Passenger < handle
    properties (SetAccess = {?Passenger, ?Controller})
        status = 'invalid' % waiting 
        coor = [-1 -1]
        timeWait = 0       
        cost = 0
        target = [278 224]
    end
    properties (Transient)
        passengerListener
    end    
    
    properties (Dependent)
        satisfaction
    end
    
    events
        DriverRequest
    end
    
    methods
        function obj = Passenger()
            if nargin == 0
            end
        end    
        
        function [] = listen(obj, ControllerInstance)
            obj.passengerListener = ControllerInstance.addpassengerlistener(obj);
        end
        
        function [] = driverrequest(obj)
            notify(obj, 'DriverRequest');
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