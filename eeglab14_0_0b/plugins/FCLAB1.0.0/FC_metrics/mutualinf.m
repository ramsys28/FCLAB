% Function by the Functional Connectivity Toolbox
% by Dongli Zhou, Wesley Thompson, and Greg Siegle
% Zhou D, Thompson T, Siegle G. (2009) NeuroImage 47:1590-1607.
function phi=mutualinf(y1,y2,sr,lambdamin,lambdamax)

if  nargin<3, lambdamin=0;lambdamax=1/2; sr=1;end

 lambdamin=lambdamin/(sr/2);
  lambdamax=lambdamax/(sr/2);
 
%sr is the sampling rate in Hz (e.g., 0.6)
% lambdamin and lambdamax are the frequency boundaries in Hz
%   The analysis operates IN BETWEEN these boundaries
%   The minimum lambdamin is 0
%   The maximum lambdamax is half the sampling rate (Nyquest frequency)
% The default (if sr, lambdamin, lambdamax are not specified) is 
%   to use the whole frequency range 

l1=length(y1);
l2=length(y2);
if (l1~=l2)
    error('the length of the two time series are not the same.');
else 
y=[y1,y2];
l=l1;
m=2;
odd=mod(l,2); %check length is odd or even
if (odd==1)
    t=(l+1)/2;
else t=l/2+1;
end
f_lambda=zeros(m,m,t);
for p1=1:m
    for p2=1:m
        f_lambda(p1,p2,:)=cpsd(y(:,p1),y(:,p2),[],[],l)/2/pi;
    end;
end;
[a,w]=cpsd(y(:,1),y(:,2),[],[],l,sr);
lambda_f=zeros(2*t-1,1);
lambda_f(t:(2*t-1),:)=w;
for j=1:(t-1)
    lambda_f(j,:)=-lambda_f((2*t-j),:);
end

temp=f_lambda;
temp1=temp(:,:,2:t);
temp2=zeros(m,m,(t-1));
for p1=1:m
    for p2=1:m
        for i=1:(t-1)
           temp2(p1,p2,i)=conj(temp1(p1,p2,(t-i)));
        end
    end;
end;

f_lambda=zeros(m,m,(2*t-1));
f_lambda(:,:,1:(t-1))=temp2;
f_lambda(:,:,t:(2*t-1))=temp;

g_lambda=zeros(m,m,(2*t-1));
for lambda=1:(2*t-1)
           warning('OFF','MATLAB:nearlySingularMatrix')
           g_lambda(:,:,lambda)=inv(f_lambda(:,:,lambda));
end
R_lambda=zeros(m,m,(2*t-1));
for lambda=1:(2*t-1)
    R_lambda(:,:,lambda)= diag(diag(g_lambda(:,:,lambda)))^(-1/2)*g_lambda(:,:,lambda)*...
        diag(diag(g_lambda(:,:,lambda)))^(-1/2);
end

Pcoh=zeros(m,m,(2*t-1));
for p1=1:m
   for p2=1:m
        for lambda=1:(2*t-1)
            Pcoh(p1,p2,lambda) = abs(R_lambda(p1,p2,lambda))^2;
        end
    end
end

%----------------specify the frequency band----------------
lw=0; up=0;
for i=t:2*t-1
    if (lambda_f(i)<lambdamin) , lw=lw+1; end
    if (lambda_f(i)>lambdamax) , up=up+1; end
end;
%----------------------------------------------------------
if (lw==0)
   Pcoh_fb=Pcoh(:,:,(up+1):(2*t-1-up));
else Pcoh_fb=Pcoh(:,:,[(up+1):(t-lw);(t+lw):(2*t-1-up)]);
end
   delta=zeros(m,m);
for p1=2:m
        for p2=1:(p1-1)
            delta(p1,p2)=-mean(log(1-Pcoh_fb(p1,p2,:)))/2/pi;
        end 
end
delta=delta+delta';


phi=(1-exp(-2*delta(1,2)))^.5;
end
