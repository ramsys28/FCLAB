function s=getallconnectivityinds(y1,y2,scan,tr,justeventmeas,scanofinterest)
% usage: s=getallconnectivityinds(y1,y2,scan,tr,justeventmeas, scanofinterest)
% computes multiple indices of fMRI functional connectivity
% all of these work on two time-series from a single
% person.
% y1 and y2 are the timeseries
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
%
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
% corrpeak - peak correlation of maximum values
% corrpeak1 - peak correlation with maximum absolute value of 
%     percent-change from first scan 
% corrscan - correlation of waveforms at a specific scan of interest
%   (specified by "scanofinterest" on the command line)
%
% LAGGED CROSS CORRELATIONS
% --------------------------
% lagged - cross correlation of smoothed timeseries
%   empirically determined smoothing within the function
%   note: we compute indices which are 1) slightly smoothed
%     but not subjected to a mongo low-pass filter and 
%     also 2) indices subjected to a 0.1 Hz lowpass filter
%   For each we return the zero-order correlation, and 
%     maximum lagged correlation.
%
% CROSS SPECTRAL CORRELATIONS
% ----------------------------
% Uses partial mutual information to compute various 
% cross spectral correlation indices
%
% coh - the coherence between timeseries at different frequencies
% lambda_coh - the corresponding frequency
% 
% phi - the normalized mutual information (2.15 from Salvador et al, 2005)
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
% ccorr - the largest canonical correlation - NOTE: Always positive
%   must inspect weight functions to understand the direction/nature
%   of the relationship. Wes will write a guide to inspecting them.
% u - the weight function for y1 (largest canonical correlation)
% v - the weight function for y2 (largest canonical correlation)
% Note: This is pretty much what we did for Siegle et al (2007) Biological Psychiatry

n1=length(y1);
if nargin<2,
  fprintf ('Must input at least two timeseries\n');
end
if nargin<3, scan=8; end
if nargin<4, tr=1.5; end
if nargin<5, justeventmeas=0; end
if nargin<6, scanofinterest=5; end

sr=1/tr;

% peak correlation
s.pcorr=corrpeak(y1,y2,scan);
%s.corrpeakabs=corrpeak1(y1,y2,scan);
s.scancorr=corrscan(y1,y2,scan,scanofinterest);

if (justeventmeas==0)
  % lagged cross correlation - useful to use with NO lowpass filtering
  % if we want to get trial-related correlations for event-related 
  % designs
  s.lagged=lagged(y1,y2,10);
  % get summary index for lagged corr
  s.zeroordercorr=s.lagged(round(length(s.lagged)./2));
  s.maxlaggedcorr=max(s.lagged);
  s.maxlag=find(s.lagged==s.maxlaggedcorr)-11;
  s.maxabslaggedcorr=max(abs(s.lagged));
  s.maxabslag=find(abs(s.lagged)==s.maxabslaggedcorr)-11;
  
  % low frequency baseline correlation 
  % (i.e., lowpass filtered at 0.1 Hz) to take out trial information
  if (1/tr) < .15
    s.lowfreqlaggedcorr=s.lagged(round(length(s.lagged)./2));
  else
    s.lowfreqlaggedcorr=lagged(lowpass(y1,sr,0.1),lowpass(y2,sr,0.1),10);
  end
  s.lowfreqzeroordercorr=s.lowfreqlaggedcorr(round(length(s.lowfreqlaggedcorr)./2));
  s.lowfreqmaxlaggedcorr=max(s.lowfreqlaggedcorr);
  s.lowfreqmaxabslaggedcorr=max(abs(s.lowfreqlaggedcorr));

  % spectral correlation

  [s.coh,s.lambda_coh] = coh(y1,y2,length(y1),sr);
  
  %mutual information
  
  s.phi=mutualinf(y1,y2);
end

% functional canonical correlation
% 0.5 smoothing is default
%[s.fcc_cr,s.fcc_y1,s.fcc_y2]=ccorr(y1,y2,8,0.5); 
[s.ccorr,s.u,s.v,s.lambda]=ccorr_cv(y1,y2,scan);

end
