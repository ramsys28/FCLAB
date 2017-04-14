function [Pxcorr,Pxcorr_lag]=Plagged(y,lag)
% does cross spectral correlation across all frequencies
% y is a matrix ( one person with different variables) 
%   each brain region is a column. Note - this can take
%   arbitrary #'s of regions. 
%lag is the max lag of the partial cross-correlation
%  i.e., the maximum lag at which you would expect one scan to
%  have a partial influence on another (i.e., independent
%  of the impact of any other region)
%  15 is not unreasonable.
% Pxcorr is the cross-partial correlation (2.21)
  %   This is in the TIME domain so it returns a
%     region x region x lag matrix with lag zero in the middle
[l m]=size(y); % m is # of variables

if nargin<2, lag=10; end % this is the number of lags that Salvador et al used
lambdamin=0;
lambdamax=pi;

odd=mod(l,2); %check length is odd or even
if (odd==1)
    t=(l+1)/2;
else t=l/2+1;
end


 

f_lambda=zeros(m,m,t);
for p1=1:m
    for p2=1:m
        f_lambda(p1,p2,:)=cpsd(y(:,p1),y(:,p2),[],[],l)/2/pi;
    end
end
[a,w]=cpsd(y(:,1),y(:,2),[],[],l);
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


f_p_lambda = zeros(m,m,(2*t-1));
for lambda=1:(2*t-1)
     for p1=2:m
        for p2=1:(p1-1)
            f_p_lambda(p1,p2,lambda)=-g_lambda(p1,p2,lambda)/(g_lambda(p1,p1,lambda)*g_lambda(p2,p2,lambda)-abs(g_lambda(p1,p2,lambda))^2);
            f_p_lambda(p2,p1,lambda)=-g_lambda(p2,p1,lambda)/(g_lambda(p1,p1,lambda)*g_lambda(p2,p2,lambda)-abs(g_lambda(p2,p1,lambda))^2);
        end
    end
end
for lambda=1:(2*t-1)
    for p=1:m
        f_p_lambda(p,p,lambda)=1/g_lambda(p,p,lambda);
    end
end

cov=zeros(m,m,(2*lag+1));
for p1=1:m
    for p2=1:m
        cov(p1,p2,:) = squeeze(invspectral(f_p_lambda(p1,p2,:),lambda_f,lag));
    end
end

%f_pp_lambda(i,j)is i,i|...,i,j  &   f_pp_lambda(j,i)is j,j|...,i,j
f_pp_lambda = zeros(m,m,(2*t-1));
for lambda=1:(2*t-1)
     for p1=2:m
        for p2=1:(p1-1)
            f_pp_lambda(p1,p2,lambda)=f_p_lambda(p1,p1,lambda)/(1-Pcoh(p1,p2,lambda));
            f_pp_lambda(p2,p1,lambda)=f_p_lambda(p2,p2,lambda)/(1-Pcoh(p1,p2,lambda));
        end
    end
end
cov_c=zeros(m,m,(2*lag+1));
for p1=1:m
    for p2=1:m
        cov_c(p1,p2,:) = squeeze(invspectral(f_pp_lambda(p1,p2,:),lambda_f,lag));
    end
end
Pxcorr=zeros(m,m,(2*lag+1));
for p1=2:m 
    for p2=1:(p1-1)
        Pxcorr(p1,p2,:) =cov(p2,p1,:)/(sqrt(cov_c(p1,p2,lag+1)*cov_c(p2,p1,lag+1))) ;
        Pxcorr(p2,p1,:) =cov(p1,p2,:)/(sqrt(cov_c(p2,p1,lag+1)*cov_c(p1,p2,lag+1))) ;
    end
end


Pxcorr_lag=-lag:1:lag;