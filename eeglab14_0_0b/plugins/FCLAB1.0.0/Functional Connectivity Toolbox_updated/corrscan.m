function scancorr=corrscan(y1,y2,scan,scanofinterest,k,norder)
% usage:r=corrscan(y1,y2,l,scannumber,k); 
% does correlation of event-related waveforms at scan scannumber
% y1 and y2 are timeseries from 1 subject, 2 regions
% l is the FIXED number of scans per trial
% k is the amount of smoothing
% NO baseline correction

if nargin<5, norder=4; k=min(floor(1/4*scan),35)+norder; end

n=length(y1);
m=n/scan; %m is the number of trials
residual=m-floor(m);
if (residual~=0)
    warning('warning:multiple','the length of the whole time series if not the multiple of the number of scans per trail.');
end
m=floor(m);
y1new=zeros(m,scan);
y2new=zeros(m,scan);
y1peak=zeros(m,1);
y2peak=zeros(m,1);
for i=1:m
    y1new(i,:)=y1(((i-1)*scan+1):(i*scan));
    y2new(i,:)=y2(((i-1)*scan+1):(i*scan));
    y1hat=meanfunction(y1new(i,:),k,norder);
    y2hat=meanfunction(y2new(i,:),k,norder);
    y1peak(i)=y1hat(scanofinterest)-y1hat(1);
    y2peak(i)=y2hat(scanofinterest)-y2hat(1);
end;
corr=corrcoef(y1peak,y2peak);
scancorr=corr(1,2);
