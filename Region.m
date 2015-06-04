classdef Region < handle
    properties (SetAccess = {?Region, ?Controller})
        probability = [0 0 0] % three levels of possibilities
        congestion = 1 % 1 to 10
        prosperity = 1 % 1 to 10
        type % 0 for driver and 1 for passenger
    end        
end