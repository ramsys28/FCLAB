function [cr,u,v,u1,v1,c,d]=ccorr_fast(y1_1,y2_1,st,lambda,k,norder) 
% performs functional canonical correlation a la Ramsey and Silverman (2006)
% y1,y2 are timeseries
% lambda is the smoothing parameter
% k is the number of knots
% cr is the largest canonical correlation - NOTE: Always positive
%   must inspect weight functions to understand the direction/nature
%   of the relationship. Wes will write a guide to inspecting them.
% u is the weight function for y1 (largest canonical correlation)
% v is the weight function for y2 (largest canonical correlation)
% usage: [cr,u,v,u1,v1]=ccorr(y1,y2,T,lambda,k); 



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
if nargin<5, norder=4; k=min(floor(1/4*scan_max),35)+norder;  end


y11=zeros(m,scan_max);
y22=zeros(m,scan_max);
for i=1:m
    if (i==1)
        y11(i,1:scan(i))=y1_1(1:sum(scan(1:i,:)));
        y22(i,1:scan(i))=y2_1(1:sum(scan(1:i,:)));
    else
    y11(i,1:scan(i))=y1_1(sum(scan(1:i-1,:))+1:sum(scan(1:i,:)));
    y22(i,1:scan(i))=y2_1(sum(scan(1:i-1,:))+1:sum(scan(1:i,:)));
    %a=median(y1new(i,:));
    %b=median(y2new(i,:));
    %y1new(i,:)=(y1new(i,:)-a)/a*100;
    %y2new(i,:)=(y2new(i,:)-b)/b*100;
    end
end
% u=zeros(k+2,1);
% v=zeros(k+2,1);
%[R,J]=canonRJ(t,k);
bsl=create_bspline_basis([0,scan_max-1],k,norder);
%[v11,v12,v22,alpha,beta]=covmatrix(y11,y22,t,k);
A1=zeros(k,k);
A2=zeros(k,k);
A3=zeros(k,k);
R=bsplinepen(bsl,int2Lfd(2),[0,scan_max-1],0);
c=zeros(k,m);
d=zeros(k,m);
for i=1:m 
    J=bsplinepen(bsl,int2Lfd(0),[0,scan(i)-1],0);
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
    A1=A1+J*c(:,i)*d(:,i)'*J;
    A2=A2+J*c(:,i)*c(:,i)'*J;
    A3=A3+J*d(:,i)*d(:,i)'*J;
end
geigstr=geigen(A1/m,(A2/m+lambda*R),(A3/m+lambda*R));
u1=geigstr.Lmat(:,1);
v1=geigstr.Mmat(:,1);
u1=u1./sqrt(sum(u1.^2));
v1=v1./sqrt(sum(v1.^2));
u=fd(u1,bsl);
v=fd(v1,bsl);
z=zeros(m,1);
w=zeros(m,1);
for i=1:m
    J=bsplinepen(bsl,int2Lfd(0),[0,scan(i)-1],1);
    z(i)=u1'*J*c(:,i);
    w(i)=v1'*J*d(:,i);
end
%cr=geigstr.values(1,1);
cr=(z'*w)^2/(z'*z+lambda*u1'*R*u1)/(w'*w+lambda*v1'*R*v1); 


