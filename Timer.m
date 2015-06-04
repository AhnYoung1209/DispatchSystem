classdef Timer < handle
    properties (SetAccess = private)
        time = 0 % starting point of time 
        speed = 1 % speed
        unit = 'second' % unit (second as default)
    end
    properties (Transient)
        timeListener
    end
    events
        TimeRefresh
    end
    
    methods
        function obj = Timer(ControllerInstance, time, speed, unit)
            if nargin == 0
                error('You have to name a controller');
            elseif nargin == 4
                obj.time = time;
                obj.speed = speed;
                obj.unit = unit;
                obj.timeListener = ControllerInstance.settimer(obj);
            end
        end
        function timepass(obj)
            obj.time = obj.time + obj.speed;
            disp(['Time is now ', num2str(obj.time), ' ', obj.unit]);
            notify(obj, 'TimeRefresh');
        end
    end
end
       
        