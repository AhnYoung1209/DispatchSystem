clear all; close all; clc; tic

%% Load the data
load data
y = data;
 
%% Create Time Series Object
% When we create a time series object, we can keep the time information
% along with the data values.  We have monthly data, so we create an array
% of dates and use it along with the Y data to create the time series
% object.
hour = repmat((0:12),60,1); hour = hour(:);
minute = repmat((0:59)',1,13); minute = minute(:);
tzero = zeros(length(hour),1);
tone = ones(length(hour),1);
time = datestr([tone * 2015,tone * 6,tone * 21,hour,minute,tzero]);
ts = timeseries(y(:),time,'name','NumberOfActivity');
ts.TimeInfo.Format = 'mmm.dd,yyyy HH:MM:SS';
tscol = tscollection(ts);
plot(ts)
return
%% Examine Trend and Seasonality
h_gca = gca;
h_gca.YScale = 'linear';

%%
% It appears that it would be easier to model the seasonal component on the
% log scale.  We'll create a new time series with a log transformation.

tscol = addts(tscol, log(ts.data), 'logAirlinePassengers');
logts = tscol.logAirlinePassengers;

%%
% Now let's plot the yearly averages, with monthly deviations superimposed.
% We want to see if the month-to-month variation within years appears
% constant.  For these manipulations treating the data as a matrix in a
% month-by-year format, it's more convenient to operate on the original
% data matrix.
t = reshape(datenum(time),12,12);
logy = log(y);
ymean = repmat(mean(logy),12,1);
ydiff = logy - ymean;
x = yr + (mo-1)/12;
plot(x,ymean,'b-',x,ymean+ydiff,'r-')
title('Monthly variation within year')
xlabel('Year')

%%
% Now let's reverse the years and months, and try to see if the
% year-to-year trend is constant for each month.
h_gca = gca;
h_gca.Position = [0.13   0.58   0.78   0.34];
subplot(2,1,2);
t = reshape(datenum(time),12,12);
mmean = repmat(mean(logy,2),1,12);
mdiff = logy - mmean;
x = mo + (yr-min(yr(:)))/12;
plot(x',mmean','b-',x',(mmean+mdiff)','r-')
title('Yearly trend within month')
xlabel('Month')

%% Model Trend and Seasonality
% Let's attempt to model this series as a linear trend plus a seasonal
% component.
subplot(1,1,1);
X = [dummyvar(mo(:)), logts.time];
[b,bint,resid] = regress(logts.data, X);
tscol = addts(tscol,X*b,'Fit1')
plot(logts)
hold on
plot(tscol.Fit1,'Color','r')
hold off
legend('Data','Fit','location','NW')

%%
% Based on this graph, the fit appears to be good.  The differences between
% the actual data and the fitted values may well be small enough for our
% purposes.
%
% But let's try to investigate this some more.  We would like the residuals
% to look independent.  If there is autocorrelation (correlation between
% adjacent residuals), then there may be an opportunity to model that and
% make our fit better.  Let's create a time series from the residuals and
% plot it.
tscol = addts(tscol,resid,'Resid1');
plot(tscol.Resid1)

%%
% The residuals do not look independent.  In fact, the correlation between
% adjacent residuals looks quite strong.  We can test this formally using a
% Durbin-Watson test.

[p,dw] = dwtest(tscol.Resid1.data, X)

%%
% A low p-value for the Durbin-Watson statistic is an indication that the
% residuals are correlated across time.  A typical cutoff for hypothesis
% tests is to decide that p<0.05 is significant. Here the very small
% p-value gives strong evidence that the residuals are correlated.
%
% We can attempt to change the model to remove the autocorrelation.
% The general shape of the curve is high in the middle and low at the ends.
% This suggests that we should allow for a quadratic trend term.  However,
% it also appears that autocorrelation will remain after we add this term.
% Let's try it.

X = [dummyvar(mo(:)), logts.time, logts.time.^2];
[b2,bint,resid2] = regress(logts.data, X);
tscol = addts(tscol,resid2,'Resid2');
plot(tscol.Resid2);
[p,dw] = dwtest(tscol.Resid2.data, X)

%%
% Adding the squared term did remove the pronounced curvature in the
% original residual plot, but both the plot and the new Durbin-Watson test
% show that there is still significant correlation in the residuals.
%
% Autocorrelation like this could be the result of other causes that are
% not captured in our X variable.  Perhaps we could collect other data that
% would help us improve our model and reduce the correlation.  In the
% absence of other data, we might simply add another parameter to the model
% to represent the autocorrelation.  Let's do that, removing the squared
% term, and using an autoregressive model for the error.
%
% In an autoregressive process, we have two stages:
%
%     Y(t) = X(t,:)*b + r(t)       % regression model for original data
%     r(t) = rho * r(t-1) + u(t)   % autoregressive model for residuals
%
% Unlike in the usual regression model when we would like the residual
% series |r(t)| to be a set of independent values, this model allows the
% residuals to follow an autoregressive model with its own error term
% |u(t)| that consists of independent values.
%
% To create this model, we want to write an anonymous function |f| to
% compute fitted values |Yfit|, so that |Y-Yfit| gives the u values:
%
%     Yfit(t) = rho*Y(t-1) + (X(t,:) - rho*X(t-1,:))*b
%
% In this anonymous function we combine |[rho; b]| into a single parameter
% vector |c|.  The resulting residuals look much closer to an uncorrelated
% series.

r = corr(resid(1:end-1),resid(2:end));  % initial guess for rho
X = [dummyvar(mo(:)), logts.time];
Y = logts.data;
f = @(c,x) [Y(1); c(1)*Y(1:end-1) + (x(2:end,:)- c(1)*x(1:end-1,:))*c(2:end)];
c = nlinfit(X,Y,f,[r;b]);

u = Y - f(c,X);
tscol = addts(tscol,u,'ResidU');
plot(tscol.ResidU);

%% Summary
% This example provides an illustration of how to use the MATLAB(R) timeseries
% object along with features from the Statistics Toolbox.  It is simple to
% use the |ts.data| notation to extract the data and supply it as input to
% any Statistics Toolbox function.  A few functions (|xbarplot|, |schart|,
% and |ewmaplot|) accept time series objects directly.
%
% More elaborate analyses are possible by using features specifically
% designed for time series, such as those in Econometrics Toolbox(TM) and
% System Identification Toolbox(TM).

toc
