function [Coh,lambda_Coh]=coh(y1,y2,l,sr)
% does cross coherence across all frequencies
% y1 y2 are timeseries. 
%   each brain region is a column. Note - this can take
%   arbitrary #'s of regions. 
% sr is the sampling rate in Hz (e.g., 0.6)
%Coh is the cross coherence and lambda_Coh is the corresponding frequency 
l1=length(y1);
l2=length(y2);
if nargin<4, sr=1; end
if nargin<3, l=l1;
end
     odd=mod(l,2); %check length is odd or even
     if (odd==1)
      t=l*2-1;
     else t=(l-1)*2;
     end

if (l1~=l2)
    error('the length of the two time series are not the same.');
else 
    
% y1=y1.*hann(length(y1),'periodic');
% y2=y2.*hann(length(y2),'periodic');
y=[y1,y2];

m=2;
%m is # of variables


f_lambda=zeros(m,m,l);
for p1=1:m
    for p2=1:m
        f_lambda(p1,p2,:)=cpsd(y(:,p1),y(:,p2),[],[],t,sr)/2/pi;
    end;
end;

[a,lambda_Coh]=cpsd(y(:,1),y(:,2),[],[],t,sr);






g_lambda=zeros(m,m,l);
for lambda=1:l
           g_lambda(:,:,lambda)=inv(f_lambda(:,:,lambda));
end
R_lambda=zeros(m,m,l);
for lambda=1:l
    R_lambda(:,:,lambda)= diag(diag(g_lambda(:,:,lambda)))^(-1/2)*g_lambda(:,:,lambda)*...
        diag(diag(g_lambda(:,:,lambda)))^(-1/2);
end

Coh=zeros(l,1);
        for lambda=1:l
            Coh(lambda,:) = abs(R_lambda(1,2,lambda))^2;
        end
end
