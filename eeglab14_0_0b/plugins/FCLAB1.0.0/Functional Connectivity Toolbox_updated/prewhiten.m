function y1=prewhiten(y,A)
% does smoothing with 
% x is the timeseries
n=length(y);
if nargin<2,A=0.7;end
A1=eye(n);
for (i=2:n)
    A1(i,i-1)=-A;
end
y1=A1*y;