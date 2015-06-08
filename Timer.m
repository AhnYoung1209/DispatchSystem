classdef Timer < handle
    
    properties (SetAccess = private)
        % 'normal', 'busy', 'free'
        status = 'nothing'
        day = 0
        hour = 0
        second = 0 % starting point of time 
        speed = 1 % speed 
        carryGener = [12 60];
    end
    properties (Transient)
        timeListener
    end
    events
        TimeRefresh
        StatusBusy
        StatusNormal        
        StatusFree
        
        GeneratePassenger
        GenerateDriver
    end
    
    methods
        function obj = Timer(ControllerInstance, speed)
            if nargin == 0
                error('You have to name a controller');
            elseif nargin == 2
                obj.speed = speed;
                obj.timeListener = ControllerInstance.settimer(obj);
            end
        end
        function timepass(obj)
            obj.second = obj.second + obj.speed;
            if(obj.second >= obj.carryGener(2))
                obj.hour = obj.hour + 1;
                obj.second = 0;
            end
            if(obj.hour >= obj.carryGener(2))
                obj.day = obj.day + 1;
                obj.hour = 0;
            end
            disp(['Time is now ', num2str(obj.day), ' day ', num2str(obj.hour), ' hour ', ...
                num2str(obj.second), ' second']);
            notify(obj, 'TimeRefresh');
            % the generation signal
            if(obj.second == 29)
                notify(obj, 'GeneratePassenger');
            elseif(obj.second == 59)
                notify(obj, 'GenerateDriver');
            end
            % the status modification signal
            if(obj.hour >= 0 && obj.hour <= 5 && ~strcmp(obj.status, 'free'))
                notify(obj, 'StatusFree');
                obj.status = 'free';
            elseif(obj.hour > 5 && obj.hour <= 8 && ~strcmp(obj.status, 'busy'))
                notify(obj, 'StatusBusy');
                obj.status = 'busy';                
            elseif(obj.hour > 8 && obj.hour <= 10 && ~strcmp(obj.status, 'normal'))
                notify(obj, 'StatusNormal');
                obj.status = 'normal';                    
            elseif(obj.hour > 10 && obj.hour <= 12 && ~strcmp(obj.status, 'busy'))
                notify(obj, 'StatusBusy');
                obj.status = 'busy';
            else
            end
        end
    end
end
       
        