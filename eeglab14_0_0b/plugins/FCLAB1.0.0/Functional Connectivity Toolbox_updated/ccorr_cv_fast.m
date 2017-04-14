function [cr,u,v,lambda]=ccorr_cv_fast(y1,y2,st,k,norder,lambda_max)

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

if nargin<6, lambda_max=1; end
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
y11=zeros(m,scan_max);
y22=zeros(m,scan_max);
for i=1:m
    if (i==1)
        y11(i,1:scan(i))=y1(1:sum(scan(1:i,:)));
        y22(i,1:scan(i))=y2(1:sum(scan(1:i,:)));
    else
    y11(i,1:scan(i))=y1(sum(scan(1:i-1,:))+1:sum(scan(1:i,:)));
    y22(i,1:scan(i))=y2(sum(scan(1:i-1,:))+1:sum(scan(1:i,:)));
    %a=median(y1new(i,:));
    %b=median(y2new(i,:));
    %y1new(i,:)=(y1new(i,:)-a)/a*100;
    %y2new(i,:)=(y2new(i,:)-b)/b*100;
    end
end 
%u=zeros(k+2,1);
%v=zeros(k+2,1);
%uu=zeros(k+2,m);
%vv=zeros(k+2,m);
lambda=0:1:lambda_max;
l_lambda=length(lambda);
cv=zeros(1,l_lambda);
c=zeros(k,m);
d=zeros(k,m);
bsl=create_bspline_basis([0,scan_max-1],k,norder);
%[v11,v12,v22,alpha,beta]=covmatrix(y11,y22,t,k);

for i=1:m 
    x = full(eval_basis(0:1:(scan(i)-1),bsl));
    temp=x;
    for l=1:k
        if (x(:,l)==zeros(scan(i),1))
            temp(:,l)=[];
        end
    end
    x=temp;
    c_temp=(x'*x)\x'*y11(i,1:scan(i))';
    d_temp=(x'*x)\x'*y22(i,1:scan(i))';
    c(1:length(c_temp),i)=c_temp;
    d(1:length(d_temp),i)=d_temp;
    
end
for i=1:l_lambda 
    x1=zeros(m,1);
    x2=zeros(m,1);
   for j=1:m
       y1new=y1;
       y1new(sum(scan(1:j-1,:))+1:sum(scan(1:j,:)))=[];
       y2new=y2;
       y2new(sum(scan(1:j-1,:))+1:sum(scan(1:j,:)))=[];
       stnew=st;
       stnew(sum(scan(1:j-1,:))+1:sum(scan(1:j,:)))=[];
       [cr1,uf,vf,u1,v1]=ccorr_fast(y1new,y2new,stnew,lambda(i),k,norder);
       J=bsplinepen(bsl,int2Lfd(0),[0,scan(j)-1],1);
       x1(j)=u1'*J*c(:,j);
       x2(j)=v1'*J*d(:,j);
   end;
   r=corrcoef(x1,x2); 
   cv(i)=r(1,2)^2;
end

[a,h]=max(cv); %find the position of lamda which gives the maximum squared correlation
lambda=lambda(h);
[cr,u,v]=ccorr_fast(y1,y2,st,lambda,k,norder);

   
    
