function [v11,v12,v22,alpha,beta]=covmatrix(x,y,t,k) %x,y are matrixes here, k is number of knots
[n,tn]=size(x);
alpha=zeros(k,n); % k is number of basic functions
beta=zeros(k,n);
v11=zeros(k,k);
v12=zeros(k,k);
% v21=zeros(k+2,k+2);
v22=zeros(k,k);
x1=zeros(1,tn);
y1=zeros(1,tn);
for i=1:tn
    x1(i)=mean(x(:,i));
    y1(i)=mean(y(:,i));
end;
alphabar=parameter(t,x1,k);
betabar=parameter(t,y1,k);
for i=1:n
    alpha(:,i)=parameter(t,x(i,:),k)-alphabar;
    beta(:,i)=parameter(t,y(i,:),k)-betabar;
    v11=v11+alpha(:,i)*alpha(:,i)';
    v12=v12+alpha(:,i)*beta(:,i)';
    v22=v22+beta(:,i)*beta(:,i)';
end;
% for i=1:n
%    alpha(:,i)=parameter(t,x(i,:),k);
%    beta(:,i)=parameter(t,y(i,:),k);
%    v11=v11+alpha(:,i)*alpha(:,i)';
%    v12=v12+alpha(:,i)*beta(:,i)';
% %    v21=v21+beta(:,i)*alpha(:,i)';
%    v22=v22+beta(:,i)*beta(:,i)'; 
% end;
v11=v11/n;
v12=v12/n;
% v21=v21/n;
v22=v22/n;
