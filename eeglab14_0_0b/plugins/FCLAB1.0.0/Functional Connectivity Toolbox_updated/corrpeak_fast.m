function pcorr=corrpeak_fast(y1,y2,st,k,norder) %l is the number of scans
% does peak correlation (max per trial)
% with timeseries from 1 subject, 2 regions
% with some fixed # of scans per trial
% NO baseline correction
% usage r=corrpeak(y1,y2,scanspertrial);
%st is the stimulus time-series 0 or 1 where 1 indicate where the stimulus
%happens
n=length(st);
m=sum(st); %m is the number of trials
scan=zeros(m,1);
m=0;
for i=1:n
  if (st(i)==1)
      m=m+1;
  end
  scan(m)=scan(m)+1;
end

scan_max=max(scan);
if nargin<4, norder=4; k=min(floor(1/4*scan_max),35)+norder; end
        
y1new=zeros(m,scan_max);
y2new=zeros(m,scan_max);
y1peak=zeros(m,1);
y2peak=zeros(m,1);
for i=1:m
    if (i==1)
        y1new(i,1:scan(i))=y1(1:sum(scan(1:i,:)));
        y2new(i,1:scan(i))=y2(1:sum(scan(1:i,:)));
    else
    y1new(i,1:scan(i))=y1(sum(scan(1:i-1,:))+1:sum(scan(1:i,:)),k,norder);
    y2new(i,1:scan(i))=y2(sum(scan(1:i-1,:))+1:sum(scan(1:i,:)),k,norder);
    %a=median(y1new(i,:));
    %b=median(y2new(i,:));
    %y1new(i,:)=(y1new(i,:)-a)/a*100;
    %y2new(i,:)=(y2new(i,:)-b)/b*100;
    end
    y1hat=meanfunction(y1new(i,1:scan(i)),k,norder);
    y2hat=meanfunction(y2new(i,1:scan(i)),k,norder);
%     y1hat=y1new(i,:);
%     y2hat=y2new(i,:);
    y1peak(i)=max(y1hat);
    y2peak(i)=max(y2hat);
end;
corr=corrcoef(y1peak,y2peak);
pcorr=corr(1,2);

