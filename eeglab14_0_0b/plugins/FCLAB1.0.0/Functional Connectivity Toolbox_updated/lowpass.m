function y_lp=lowpass(y,sr,f,order)
%'y'is the input timeseries; 'f' is the cut-off frequency ; 'sr' is the sample rate frequency; 'order' is the order of the filter 
if nargin<4, order=10; end
fNorm = f/sr*2;
[b,a] = butter(order, fNorm);
y_lp= filtfilt(b, a, y);