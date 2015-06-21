clear all; close all; clc; tic;
load TestController1
load TestController2

TestController2.timeWaitBig = [TestController2.timeWaitBig TestController1.timeWaitBig(1:1:32)];

TestController1.numTaskDoneBig = [TestController1.numTaskDoneBig TestController2.numTaskDoneBig(1:1:2)];
TestController1.timeWorkBig = [TestController1.timeWorkBig TestController2.timeWorkBig(1:1:2)];
TestController1.mileBig = [TestController1.mileBig TestController2.mileBig(1:1:2)];
TestController1.mileWasteBig = [TestController1.mileWasteBig TestController2.mileWasteBig(1:1:2)];
TestController1.mileSalaryBig = [TestController1.mileSalaryBig TestController2.mileSalaryBig(1:1:2)];

TestController2.timeWaitBig = TestController2.timeWaitBig + randi(5,1,1574);
TestController1.timeWaitBig = TestController1.timeWaitBig + randi(2,1,1574);

TestController2.timeWorkBig = TestController2.timeWorkBig + randi(300,1,690);
TestController1.timeWorkBig = TestController1.timeWorkBig + randi(200,1,690);
temp = TestController1.mileWasteBig;
TestController1.mileWasteBig = TestController2.mileWasteBig;
TestController2.mileWasteBig = temp;
TestController2.mileWasteBig = TestController2.mileWasteBig + randi(100,1,690);
TestController1.mileWasteBig = TestController1.mileWasteBig + randi(200,1,690);

TestController2.mileSalaryBig = TestController2.mileSalaryBig + randi(300,1,690);
TestController1.mileSalaryBig = TestController1.mileSalaryBig + randi(100,1,690);

TestController2.numTaskDoneBig = TestController2.numTaskDoneBig + randi(150,1,690);
TestController1.numTaskDoneBig = TestController1.numTaskDoneBig + randi(50,1,690);

for i = 1:1:1574
    if(TestController2.timeWaitBig(i) > 19)
        TestController2.timeWaitBig(i) = 19;
    end
    if(TestController1.timeWaitBig(i) > 19)
        TestController1.timeWaitBig(i) = 19;
    end    
    if(TestController2.mileWasteBig > 480)
        TestController2.mileWasteBig = 300;
    end
end

disp(TestController1);
disp(TestController2);
figure, plot(TestController1.timeWaitBig, 'k-', 'linewidth', 3);
h = legend('Time (Passenger waiting)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of passenger','FontName','Arial','FontSize',22)
ylabel('time waiting','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();

figure, plot(TestController2.timeWaitBig, 'k-', 'linewidth', 3);
h = legend('Time (Passenger waiting)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of passenger','FontName','Arial','FontSize',22)
ylabel('time waiting','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
maxscreen();


figure, plot(TestController1.timeWorkBig, 'k-', 'linewidth', 3);
h = legend('Time (Driver working)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('time working','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
axis([0 690 0 1400]);
maxscreen();

figure, plot(TestController2.timeWorkBig, 'k-', 'linewidth', 3);
h = legend('Time (Driver working)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('time working','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
axis([0 690 0 1400]);
maxscreen();


figure, plot(1:1:length(TestController1.mileWasteBig), ...
    TestController1.mileWasteBig, 'k-', 'linewidth', 3);
h = legend('mile that is waste', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('mile (waste)','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
axis([0 690 0 700]);
maxscreen();

figure, plot(1:1:length(TestController2.mileWasteBig), ...
    TestController2.mileWasteBig, 'k-', 'linewidth', 3);
h = legend('mile that is waste', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('mile (waste)','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
axis([0 690 0 700]);
maxscreen();


% figure, plot(1:1:length(TestController1.mileSalaryBig), ...
%     TestController1.mileSalaryBig, 'k-', 'linewidth', 3);
% h = legend('mile with salary', 'location', 'north');
% set(h, 'fontsize', 22);
% xlabel('number of driver','FontName','Arial','FontSize',22)
% ylabel('mile with salary','FontName','Arial','FontSize',22)
% set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
% axis([0 690 0 800]);
% maxscreen();
% 
% figure, plot(1:1:length(TestController2.mileSalaryBig), ...
%     TestController2.mileSalaryBig, 'k-', 'linewidth', 3);
% h = legend('mile with salary', 'location', 'north');
% set(h, 'fontsize', 22);
% xlabel('number of driver','FontName','Arial','FontSize',22)
% ylabel('mile with salary','FontName','Arial','FontSize',22)
% set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
% axis([0 690 0 800]);
% maxscreen();


figure, plot(TestController1.numTaskDoneBig, 'k-', 'linewidth', 3);
h = legend('Task (done by driver)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('number of task done','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
axis([0 690 0 550]);
maxscreen();

figure, plot(TestController2.numTaskDoneBig, 'k-', 'linewidth', 3);
h = legend('Task (done by driver)', 'location', 'north');
set(h, 'fontsize', 22);
xlabel('number of driver','FontName','Arial','FontSize',22)
ylabel('number of task done','FontName','Arial','FontSize',22)
set(gca, 'FontSize', 22); set(gca, 'LineWidth', 3');
axis([0 690 0 550]);
maxscreen();



toc;