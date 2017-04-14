function yhat=meanfunction(y,k,norder)
% does smoothing with 
% x is the timeseries
% t is a vector with all used scans (e.g., 1:8)
% k is the number of knots, which is optional.
%   if not specified then we choose knots empirically
%   using Matt Wand's rule of thumb
% usage: yhat=meanfunction(x,t,k);
n=length(y);
t1=1:1:n;
if nargin<2, norder=4; k=min(floor(1/4*n),35)+norder;  end
if (n==4)
    if (k>4)
        k=4;
    end
end
if (n==3)
    if (k>3)
        k=3;
    end
    if (norder>3)
        norder=3;
    end
end
if (n==2)
    if (k>2)
        k=2;
    end
    if (norder>2)
        norder=2;
    end
end
    

bsl=create_bspline_basis([min(t1),max(t1)],k,norder);  %k+2 is the number of basis 
bslobj=fdpar(bsl);
[fdobj] =smooth_basis(t1,y, bslobj);
yhat=eval_fd(t1,fdobj);

