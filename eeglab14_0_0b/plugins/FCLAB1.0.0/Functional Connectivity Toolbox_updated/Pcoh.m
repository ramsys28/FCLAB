function [PCoh,lambda_PCoh]=Pcoh(y,l,sr)
% does cross coherence across all frequencies
% y is a matrix ( one person with different variables) 
%   each brain region is a column. Note - this can take
%   arbitrary #'s of regions. 
% sr is the sampling rate in Hz (e.g., 0.6)
%PCoh is the partial cross coherence and lambda_PCoh is the corresponding frequency 
[l1,m]=size(y);

%if nargin<5, k=70; norder=4; end
if nargin<3, sr=1; end
if nargin<2, l=l1;
end
     odd=mod(l,2); %check length is odd or even
     if (odd==1)
      t=l*2-1;
     else t=(l-1)*2;
     end


f_lambda=zeros(m,m,l);
for p1=1:m
    for p2=1:m
        f_lambda(p1,p2,:)=cpsd(y(:,p1),y(:,p2),[],[],t)/2/pi;
    end;
end;
[a,lambda_PCoh]=cpsd(y(:,1),y(:,2),[],[],t,sr);





g_lambda=zeros(m,m,l);
for lambda=1:l
           g_lambda(:,:,lambda)=inv(f_lambda(:,:,lambda));
end
R_lambda=zeros(m,m,l);
for lambda=1:l
    R_lambda(:,:,lambda)= diag(diag(g_lambda(:,:,lambda)))^(-1/2)*g_lambda(:,:,lambda)*...
        diag(diag(g_lambda(:,:,lambda)))^(-1/2);
end

PCoh=zeros(m,m,l);
for p1=1:m
   for p2=1:m
        for lambda=1:l
            PCoh(p1,p2,lambda) = abs(R_lambda(p1,p2,lambda))^2;
        end
    end
end

