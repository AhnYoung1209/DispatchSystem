clear; close all; clc; tic;
warning off %#ok<WNOFF>
% WARNING
% Please comment the following command based on your requirement
dbstop if error
TestController = Controller();
TestTimer = Timer(TestController, 1);
for i = 1:1:780*2
    TestTimer.timepass;
%     pause(1)
end 

%%
disp([num2str(TestController.numGiveUp), ' passengers give up']);
close all

figure, plot(TestController.timeWaitBig, 'b-', 'linewidth', 3);
h = legend('Time (Passenger waiting)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of passenger','FontName','Arial','FontSize',22)
ylabel('time waiting','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController.timeWorkBig, 'b-', 'linewidth', 3);
h = legend('Time (Driver working)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('time working','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController.numTaskDoneBig, 'b-', 'linewidth', 3);
h = legend('Task (done by driver)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('number of task done','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController.numTaskDoneTotalBig, 'b-', 'linewidth', 3);
h = legend('Task (done by all driver)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('second','FontName','Arial','FontSize',22)
ylabel('number of task done by all driver','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(1:1:length(TestController.mileBig), ...
    TestController.mileBig, 'b-', 'linewidth', 3);
h = legend('mile (total)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('total mile','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(1:1:length(TestController.mileSalaryBig), ...
    TestController.mileSalaryBig, 'b-', 'linewidth', 3);
h = legend('mile with salary', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('mile with salary','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(1:1:length(TestController.mileWasteBig), ...
    TestController.mileWasteBig, 'b-', 'linewidth', 3);
h = legend('mile that is waste', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('mile (waste)','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController.numGiveUpBig, 'b-', 'linewidth', 3);
h = legend('number of passenger give up', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('second','FontName','Arial','FontSize',22)
ylabel('number of passenger give up','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController.numLeaveBig, 'b-', 'linewidth', 3);
h = legend('number of driver leaving his job', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('second','FontName','Arial','FontSize',22)
ylabel('number of driver leaving his job','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController.numZoneBig, 'b-', 'linewidth', 3);
h = legend('Activity in special zone', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('second','FontName','Arial','FontSize',22)
ylabel('number of activity happened in this zone','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();
toc