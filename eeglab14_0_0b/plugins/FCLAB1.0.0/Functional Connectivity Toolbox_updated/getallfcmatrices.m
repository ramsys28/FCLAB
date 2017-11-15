function s=getallfcmatrices(y,scan,tr,justeventmeas,scanofinterest,lag)
% usage: s=getallfcmatrices(y,scan,tr,justeventmeas,scanofinterest)
% allows generation of connectivity matrices based on input time-series from a single
% person.
% y is a matrix ( one person with different variables) 
%   each brain region is a column. Note - this can take
%   arbitrary #'s of regions. 
% scan is the number of scans in each trial in a slow-event-
%   related design (or per block, in a block design where connectivity 
%   within blocks is of interest)
% tr is the number of seconds between samples (scans)
% justeventmeas indicates that only event-related measures
%   should be calculated (e.g., when only certain trials
%   are being passed to the routine
% scanofinterest is a specific scan number within trials 
%   at which something interesting is hypothesized to 
%   occur (e.g., the peak of the BOLD response)
% lag is the maximum lag to calculate cross-correlation.
% Toolkit by Dongli Zhou, Wesley Thompson, and Greg Siegle
%
%
% We assume data is centered around first scan
%  i.e., first scan is subtracted from all subsequent scans
%  and data is converted to %-change from the time-series
%  median
%
% PEAK CORRELATIONS via Riemann
% -----------------------------
% corrpeak - matrix of peak correlation of maximum values
% corrscan - matrix of correlation of waveforms at a specific scan of interest
%   (specified by "scanofinterest" on the command line)
%
% LAGGED CROSS CORRELATIONS
% --------------------------
% xcorr - three-dimensional matrix of cross correlation of timeseries 
%   within the function. For each we return the zero-order correlation, and 
%   lagged correlation. 
% lag_xcorr - A vector of integers indicates the lags corresponding to
%   the estimated cross-correlations. e.g. xcorr[:,:,xcorr_lag(k)] is the
%   cross corrlation between time-series at lag xcorr_lag(k).
%
% CROSS SPECTRAL CORRELATIONS
% ----------------------------
% Uses partial mutual information to compute various 
% cross spectral correlation indices
%
% coh - three-dimensional matrix of the coherence between timeseries 
%   at different frequencies. 
% lambda_coh - A vector of positive values indicates the frequencies
%   corresponding to the estimated cross-coherence. e.g. coh[:,:,lambda_coh(k)] is the
%   cross corrlation between time-series at frequency lambda_coh(k).
% 
% phi - matrix of the normalized mutual information (2.15 from Salvador et al, 2005)
%   *** this is the one people "usually" want (we think...)
%   and represents the partial spectral correlation summarized over
%   all frequencies within the band specified 
%   NOTE: This is a structure with correlations of every region
%     with every other region. So for 2 regions we would get back
%     a symmetric 2x2 matrix 
% from Salvador, R. et al, (2005)., Phil Trans R Soc B, 360, 937-946
%
% FUNCTIONAL CANONICAL CORRELATION
% --------------------------------
% performs functional canonical correlation a la Ramsey and Silverman (2006)
% ccorr - matrix of the largest canonical correlation - NOTE: Always positive
%   must inspect weight functions to understand the direction/nature
%   of the relationship. Wes will write a guide to inspecting them.

% Note: This is pretty much what we did for Siegle et al (2007) Biological Psychiatry
[n,m]=size(y);
if nargin<2,
  fprintf ('Must input at least two timeseries\n');
end
if nargin<3, scan=8; end
if nargin<4, tr=1.5; end
if nargin<5, justeventmeas=0; end
if nargin<6, scanofinterest=5; end
if nargin<7, lag=10;end

sr=1/tr;

% peak correlation
s.pcorr=eye(m);
s.scancorr=eye(m);
for i=1:(m-1)
    for j= (i+1):m
        s.pcorr(i,j)=corrpeak(y(:,i),y(:,j),scan);
        s.pcorr(j,i)=s.pcorr(i,j);
        s.scancorr(i,j)=corrscan(y(:,i),y(:,j),scan,scanofinterest);
        s.scancorr(j,i)=s.scancorr(i,j);
    end
end

if (justeventmeas==0)
    
  % cross-correlation
  
  s.xcorr=zeros(m,m,2*lag+1);
  for l=1:2*lag+1
      s.xcorr(:,:,l)=eye(m);
  end
  
  for i=1:(m-1)
      for j= (i+1):m
          s.xcorr(i,j,:)=lagged(y(:,i),y(:,j),lag);
          s.xcorr(j,i,:)=s.xcorr(i,j,:);
      end
  end
  [temp,s.lag_xcorr]=lagged(y(:,i),y(:,j),lag);
          
  % spectral correlation
 
  s.coh=zeros(m,m,n);
  for l=1:n
      s.coh(:,:,l)=eye(m);
  end
  for i=1:(m-1)
      for j= (i+1):m
          s.coh(i,j,:)=coh(y(:,i),y(:,j),n,sr);
          s.coh(j,i,:)=s.coh(i,j,:);
      end
  end
  [temp,s.lambda_coh]=coh(y(:,i),y(:,j),n,sr);
  
  %mutual information
  
  s.phi=eye(m);
  for i=1:(m-1)
    for j= (i+1):m
        s.phi(i,j)=mutualinf(y(:,i),y(:,j));
        s.phi(j,i)=s.phi(i,j);
    end
  end
  
end

% functional canonical correlation
s.ccorr=eye(m);
  for i=1:(m-1)
    for j= (i+1):m
        s.ccorr(i,j)=ccorr_cv(y(:,i),y(:,j),scan);
        s.ccorr(j,i)=s.ccorr(i,j);
    end
  end

end