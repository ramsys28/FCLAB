function [cr,u,v,u1,v1]=ccorr(y1_1,y2_1,T1,lambda,k,norder)
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
% usage: [cr,u,v,u1,v1]=ccorr(y1,y2,T,lambda,k); 
t=0:1:(T1-1);
l=length(t);

if nargin<5, norder=4; k=min(floor(1/4*l),35)+norder; end

n=length(y1_1);
m=n/l; %m is the number of trials
residual=m-floor(m);
if (residual~=0)
    warning('warning:multiple','the length of the whole time series if not the multiple of the number of scans per trail.');
end
m=floor(m);
y11=zeros(m,l);
y22=zeros(m,l);
for j=1:m
  y11(j,:)=y1_1((l*(j-1)+1):(l*j));
  y22(j,:)=y2_1((l*(j-1)+1):(l*j));
  
end; 
% u=zeros(k+2,1);
% v=zeros(k+2,1);
[R,J]=canonRJ(t,k);
%[u1,v1,cr]=eigen(y11,y22,t,k,R,J,lambda);

bsl=create_bspline_basis([min(t),max(t)],k,4);
[v11,v12,v22,alpha,beta]=covmatrix(y11,y22,t,k);
geigstr=geigen(J*v12*J,(J*v11*J+lambda*R),(J*v22*J+lambda*R));
u1=geigstr.Lmat(:,1);
v1=geigstr.Mmat(:,1);
u1=u1./sqrt(sum(u1.^2));
v1=v1./sqrt(sum(v1.^2));
u=fd(u1,bsl);
v=fd(v1,bsl);
z=zeros(m,1);
w=zeros(m,1);
for i=1:m
    z(i)=u1'*J*alpha(:,i);
    w(i)=v1'*J*beta(:,i);
end
%cr=geigstr.values(1,1);
cr=(z'*w)^2/(z'*z+lambda*u1'*R*u1)/(w'*w+lambda*v1'*R*v1); 


