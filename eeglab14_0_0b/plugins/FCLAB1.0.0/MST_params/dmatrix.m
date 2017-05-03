function y = dmatrix(x)
% d=dmatrix(data =[N x p]), data=[#vectors x dimensionality of the vector-space]
% data=[channels x time-instants]
% or data=[#trials x  time-imstants] 

[m,n]=size(x);



a=x*x';
e=ones(m,m) ;
d=diag(diag(a))*e + e*diag(diag(a))-2*a ;



y=d;


