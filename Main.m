clear; close all; clc; tic;
% warning off %#ok<WNOFF>
% dbstop if error
TestController = Controller();
TestTimer = Timer(TestController, 0, 1, 'second');
for i = 1:1:300
    TestTimer.timepass;
%     pause(1)
end 
toc