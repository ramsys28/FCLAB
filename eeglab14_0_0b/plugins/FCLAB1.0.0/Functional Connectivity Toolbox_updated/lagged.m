function [xcorr,xcorr_lag]=lagged(y1,y2,lag)
%xcorr is the cross-coorelation, xcorr_lag is the lag corresponding the
%cross-correlation
% usage: r1=lagged(y1,y2,lag,k);
% smooths data then computes lagged cross correlation
% zero order correlation is in the middle
% y1 y2 are timeseries.
% lag is the maximum lag.
% k is the smoothness (computed by a rule of thumb if not specified
n=length(y1);
m=length(y2);
%if nargin<4, k=60; norder=4; end
if nargin<3, lag=10; end

if (m~=n)
    error('the length of the two time series are not the same.');
else 
  
y1bar=sum(y1)/n;
y2bar=sum(y2)/m;
  

    r=zeros(1,2*n-1);
    y1y2=(y1-y1bar).*(y2-y2bar);
    y1square=(y1-y1bar).*(y1-y1bar);
    y2square=(y2-y2bar).*(y2-y2bar);
      
    rx=sum(y1square);
    ry=sum(y2square);
    rxry=rx*ry;
 for i=1:(2*n-1)
    if (i<=n-1)
      for j=1:i
        r(i)=r(i)+(y1(j+n-i)-y1bar)*(y2(j)-y2bar);
      end;
     r(i)=r(i)/sqrt(rxry);
    elseif (i==n)
         r(i)=sum(y1y2)/sqrt(rxry);
    else  
              for j=1:(2*n-i)
                r(i)=r(i)+(y1(j)-y1bar)*(y2(j+i-n)-y2bar);
              end;
         r(i)=r(i)/sqrt(rxry);
   end;
 end;

xcorr=zeros(1,(2*lag+1));
xcorr(1,:)=r(1,(n-lag):(n+lag));
xcorr_lag=-lag:1:lag;
end; 
