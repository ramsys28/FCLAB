function pcorr=corrpeak(y1,y2,scan,k,norder) %l is the number of scans
% does peak correlation (max per trial)
% with timeseries from 1 subject, 2 regions
% with some fixed # of scans per trial
% NO baseline correction
% usage r=corrpeak(y1,y2,scanspertrial);
if nargin<4, norder=4; k=min(floor(1/4*scan),35)+norder; end
n=length(y1);
m=n/scan; %m is the number of trials
residual=m-floor(m);
if residual~=0
    warning ('warning:multiple','the length of the whole time series if not the multiple of the number of scans per trail.');
end
m=floor(m);
y1new=zeros(m,scan);
y2new=zeros(m,scan);
y1peak=zeros(m,1);
y2peak=zeros(m,1);
for i=1:m
    y1new(i,:)=y1(((i-1)*scan+1):(i*scan));
    y2new(i,:)=y2(((i-1)*scan+1):(i*scan));
    %a=median(y1new(i,:));
    %b=median(y2new(i,:));
    %y1new(i,:)=(y1new(i,:)-a)/a*100;
    %y2new(i,:)=(y2new(i,:)-b)/b*100;
     y1hat=meanfunction(y1new(i,:),k,norder);
     y2hat=meanfunction(y2new(i,:),k,norder);
     
     y1peak(i)=max(y1hat);
     y2peak(i)=max(y2hat);
end;
corr=corrcoef(y1peak,y2peak);
pcorr=corr(1,2);

