function [stats, aval1, avect1] = descser(y, tit)
% descser  - Computes and displays descriptive statistics on a series set.
%    stats = descser(y, tit)
%  y      > (nxm) m series of n observations each.
%  tit    > (mx?) matrix which contains the names of the series.
%  stats  < (mx14) matrix of statistics. Includes number of valid
%           (non-missing) observations, mean, standard deviations,
%           skewness, excess kurtosis, quartiles, lowest value, observation
%           with the lowest value, largest value and observation with the
%           largest value, Jarque-Bera and Dickey-Fuller statistics.
%  aval1  < sorted eigenvalues of the variance-covariance matrix
%  avect1 < sorted eigenvectors of the variance-covariance matrix
%           (principal components).
% The correlation matrix and the eigenstructure is only computed if
% the sample contains no missing data.
%
% 6/3/97

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

[n,m] = size(y);
if n <= 1, e4error(7); end

if     nargin == 1, titf = 0;
elseif nargin == 2
   titf = 1;
   if (size(tit,1) > 0) & (size(tit,1) ~= m)
     e4warn(1); titf = 0;
   elseif (size(tit,1) == 0)
     titf = 0;
   end
end

for i=1:m
   missndx  = find(isnan(y(:,i)));
   yi       = y(~isnan(y(:,i)),i);
   nobs(i)  = size(yi,1);

   q50(i)   = median(yi);
   ydum     = yi(yi < q50(i));  q25(i) = median(ydum);  
   ydum     = yi(yi >= q50(i)); q75(i) = median(ydum);  
  
   meany(i) = mean(yi);
   stdy(i)  = std(yi);
   sime(i)  = mean( (yi-meany(i)).^3 )/stdy(i)^3;
   curt(i)  = mean( (yi-meany(i)).^4 )/stdy(i)^4 - 3;
   jb(i)    = nobs(i)*( (sime(i)^2)/6  +  (curt(i)^2)/24  );
  
   if size(missndx,1)
      yi = y(:,i);
      yi(missndx) = meany(i)*ones(size(missndx));
      dft1(i) = NaN;
      dft2(i) = NaN;
   else
      nolag1=fix(sqrt(size(yi,1)));
      dft = augdft(yi,nolag1);
      dft1(i) = dft(3);
      nolag2=1;
      dft = augdft(yi,nolag2);
      dft2(i) = dft(3);
   end
   [maxy(i), imaxy(i)] = max( yi );
   [miny(i), iminy(i)] = min( yi );
end

fprintf(e4file,'\n');
fprintf(e4file,'*****************  Descriptive statistics  *****************\n');
fprintf(e4file,'\n');
for i=1:m
    if titf
       titstr = ['---  Statistics of ' deblank(tit(i,:)) ' ---\n'];
    else  
       titstr = ['---  Statistics of series # ' int2str(i) ' ---\n'];
    end
    fprintf(e4file,titstr);
    fprintf(e4file,sprintf('Valid observations = %4d\n', nobs(i) ));
    fprintf(e4file,'Mean               = %8.4f, t test = %8.4f\n', ...
        meany(i), meany(i)/(stdy(i)/sqrt(nobs(i))) );
    fprintf(e4file,'Standard deviation = %8.4f\n', stdy(i) );
    fprintf(e4file,'Skewness           = %8.4f\n', sime(i) );            
    fprintf(e4file,'Excess Kurtosis    = %8.4f\n', curt(i) );
    fprintf(e4file,'Quartiles          = %8.4f, %8.4f, %8.4f\n', q25(i), q50(i), q75(i) );
    fprintf(e4file,'Minimum value      = %8.4f, obs. # %4d\n', miny(i), iminy(i) );
    fprintf(e4file,'Maximum value      = %8.4f, obs. # %4d\n', maxy(i), imaxy(i) );
    fprintf(e4file,'Jarque-Bera        = %8.4f\n', jb(i)  );
    fprintf(e4file,'Dickey-Fuller      = %8.4f, computed with %3.0f lags\n', dft1(i), nolag1);
    fprintf(e4file,'Dickey-Fuller      = %8.4f, computed with %3.0f lags\n', dft2(i), nolag2);
 
    yi = y(:,i);
    missndx  = find(isnan(yi));
    if size(missndx,1)
      yi(missndx) = meany(i)*ones(size(missndx));
    end
    
    atipl = find(abs(yi-meany(i)) > 2*stdy(i));
    fprintf(e4file,'Outliers list\n');
    fprintf(e4file,' Obs #         Value\n');
    for j=1:size(atipl,1)
        fprintf(e4file,sprintf('%4d     %12.4f\n', atipl(j), yi(atipl(j))) );
    end
    fprintf(e4file,'\n');
end

fprintf(e4file,'\n');
if (~any(any(isnan(y)))) & (m > 1);
    fprintf(e4file,'Sample correlation matrix\n');
    corrm = corrcoef(y);
    for i=1:m
        fprintf(e4file,'%6.4f  ', corrm(i,:));
        fprintf(e4file,'\n');
    end
    
    varm  = cov(y);
    [avect1, aval1] = eig(corrm); 
    [aval1, ind] = sort(diag(aval1)); 
    aval1  = flipud(aval1);
    avect1 = fliplr(avect1(:,ind'));
    suma = sum(aval1);

%    fprintf(e4file,' ');
    fprintf(e4file,'Eigen structure of the correlation matrix\n');
    fprintf(e4file,'  i eigenval %%var | Eigen vectors\n');
    for i=1:m
       str1 = sprintf('%3d %8.4f %3.2f | ', i, aval1(i), aval1(i)/suma); 
       str2 = sprintf(' %7.4f', avect1(:,i));
       fprintf(e4file,[str1 str2 '\n']);
    end
end
fprintf(e4file,'************************************************************\n');

stats = [nobs' meany' stdy' sime' curt' q25' q50' q75' maxy' imaxy' miny' iminy' jb' dft1' dft2'];
