function prtest(theta, din, labtheta, y, it, fval, g, h, dt, corrm, t)
% prtest   - Presents a standard output of estimation results.
%    prtest(theta, din, lab, y, it, fval, g, h, dt, corrm, t)
% theta > optimal value of the parameter vector.
% din   > matrix which stores a description of the model dynamics.
% lab   > string matrix of parameters labels.
% y     > data used in estimation.
% it    > number of iterations.
% fval  > value of the objective function.
% g     > gradient of the objective function.
% h     > hessian of the objective function.
% dt    > (optional) exact standard deviation of the estimates.
% corrm > (optional) parameter correlation matrix.
% t     > (optional) computing time in minutes [(toc)/60].
%
% 10/1/97

% Copyright (C) 1997 Jaime Terceiro
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details. 
% 
% You should have received a copy of the GNU General Public License
% along with this file.  If not, write to the Free Software Foundation,
% 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

global E4OPTION
e4file = E4OPTION(20);

if nargin < 8, e4error(3); end
if      nargin == 8, dt = []; corrm = []; t = 0;
elseif  nargin == 9, corrm = []; t = 0;
elseif  nargin == 10, t = 0;
end

n = size(y,1);
if n <= 0, e4error(11); end

exact= any(size(dt));
rest = (size(theta,2) > 1);
k    = size(theta,1);
r    = hessp(h);
invh = r\ (r'\(eye(size(h))));
apdt = sqrt(diag(invh));

if size(labtheta,1) == 0, labtheta = e4strmat(ones(k,12)*32); end
if size(labtheta,2) < 14
   labtheta = [labtheta e4strmat(ones(k,14-size(labtheta,2))*32)];
end
if rest
    ndx = (theta(:,2)==0);
    dt2 = zeros(k,1); g2 = dt2; apdt2 = dt2; tt = dt2;
    g2(ndx) = g; apdt2(ndx) = apdt; tt(ndx) = theta(ndx,1)./apdt2(ndx,1);
    if exact, dt2(ndx) = dt; tt(ndx) = theta(ndx,1)./dt2(ndx,1); end

    ndx1= find(theta(:,2)~=0);
    labtheta(ndx1,size(labtheta,2)) = e4strmat(ones(size(ndx1))*42);
    M = k - size(ndx1,1);
else
    g2 = g; apdt2 = apdt; tt = theta(:,1)./apdt2;
    if exact, dt2 = dt; tt = theta(:,1)./dt2; end
    M = k;
end

fprintf(e4file,'\n');
fprintf(e4file,'******************** Results from model estimation ********************\n');
fprintf(e4file,'  Objective function: %8.4f\n', fval);
fprintf(e4file,'     # of iterations: %4d\n', it);
fprintf(e4file,'Information criteria: AIC = %8.4f, SBC = %8.4f\n', (2*fval + 2*M)/n, (2*fval + M*log(n))/n );
if t, fprintf(e4file,'         Time (min.): %6.2f\n', t ); end
fprintf(e4file,'\n');
if exact
    cabecera = ['Parameter          Estimate    Std. Dev.       t-test     Gradient\n'];
else
    cabecera = ['Parameter          Estimate    Appr.Std.Dev.   t-test     Gradient\n'];
end
fprintf(e4file,cabecera);
for i=1:size(theta,1)
    if exact, str = sprintf('%14s %12.4f %12.4f %12.4f %12.4f\n', ...
           labtheta(i,:), theta(i,1), dt2(i), tt(i), g2(i) );
    else      str = sprintf('%14s %12.4f %12.4f %12.4f %12.4f\n', ...
           labtheta(i,:), theta(i,1), apdt2(i), tt(i), g2(i) );
    end
    fprintf(e4file,str);
end

if rest, fprintf(e4file,'* denotes constrained parameter\n'); end
fprintf(e4file,'\n');
if (k > 1)
    fprintf(e4file,'************************* Correlation matrix **************************\n');
    if ~size(corrm,1);
        corrm = inv(diag(apdt))*invh*inv(diag(apdt));
    end
    if rest
        ndx = find(theta(:,2)==0);
        labtheta = labtheta(ndx,:);
    end
    for i=1:size(corrm,1), 
        fprintf(e4file,[sprintf('%s', labtheta(i,1:12)) sprintf('%6.2f',corrm(i,1:i)) '\n']); 
    end
    fprintf(e4file,'\n');
    fprintf(e4file,'           Condition number = %8.4f\n', cond(corrm));
    fprintf(e4file,'Reciprocal condition number = %8.4f\n', rcond(corrm));
end
fprintf(e4file,'***********************************************************************\n');
fprintf(e4file,'\n');
