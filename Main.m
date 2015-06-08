clear; close all; clc; tic;
warning off %#ok<WNOFF>
% WARNING
% Please comment the following command based on your requirement
dbstop if error
TestController = Controller();
TestTimer = Timer(TestController, 1);
for i = 1:1:780
    TestTimer.timepass;
%     pause(1)
end 
disp([num2str(TestController.numGiveUp), ' passengers give up']);
figure, plot(TestController.timeWaitBig);
legend('Time (Passenger waiting)');
toc