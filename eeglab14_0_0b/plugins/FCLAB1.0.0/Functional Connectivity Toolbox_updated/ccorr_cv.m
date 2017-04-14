function [cr,u,v,lambda]=ccorr_cv(y1,y2,scan,k,norder,lambda_max)

% performs functional canonical correlation a la Ramsey and Silverman (2006)
% y1,y2 are timeseries
% T is the number of scans per trial
% lambda is the smoothing parameter
% k is the number of knots
% cr is the largest canonical correlation - NOTE: Always positive
%   must inspect weight functions to understand the direction/nature
%   of the relationship. Wes will write a guide to inspecting them.
% u is the weight function for y1 (largest canonical correlation)
% v is the weight function for y2 (largest canonical correlation)
%lambda is the value who controls the smoothness
% usage: [cr,u,v,lambda]=ccorr(y1,y2,scan,lambda,k); 
t=0:1:(scan-1);
l=length(t);
if nargin<6, lambda_max=1; end
if nargin<4, norder=4; k=min(floor(1/4*l),35)+norder; end
n=length(y1);
m=n/l; %m is the number of trials
residual=m-floor(m);
if (residual~=0)
    warning('warning:multiple','the length of the whole time series if not the multiple of the number of scans per trail.');
end
m=floor(m);
y11=zeros(m,l);
y22=zeros(m,l);
for j=1:m
  y11(j,:)=y1((l*(j-1)+1):(l*j));
  y22(j,:)=y2((l*(j-1)+1):(l*j));
end; 
%u=zeros(k+2,1);
%v=zeros(k+2,1);
%uu=zeros(k+2,m);
%vv=zeros(k+2,m);
lambda=0:1:lambda_max;
l_lambda=length(lambda);
cv=zeros(1,l_lambda);
[v11,v12,v22,alpha,beta]=covmatrix(y11,y22,t,k);
[R,J]=canonRJ(t,k);
for i=1:l_lambda 
    x1=zeros(m,1);
    x2=zeros(m,1);
   for j=1:m
       y1new=y1;
       y1new((l*(j-1)+1):j*l)=[];
       y2new=y2;
       y2new((l*(j-1)+1):j*l)=[];
       [cr1,uf,vf,u1,v1]=ccorr(y1new,y2new,scan,lambda(i),k,norder);
       x1(j)=u1'*J*alpha(:,j);
       x2(j)=v1'*J*beta(:,j);
   end;
   r=corrcoef(x1,x2); 
   cv(i)=r(1,2)^2;
end

[a,h]= max(cv); %find the position of lamda which gives the maximum squared correlation
lambda=lambda(h);
[cr,u,v]=ccorr(y1,y2,scan,lambda,k,norder);

   
    
