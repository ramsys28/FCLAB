function plot(Lfdobj)
%  Plots a linear differential operator object.  
%  The coefficients \beta_j defining the homogeneous
%    part of the operator are plotted first, followed
%    by the coefficients for the forcing functions.
m       = Lfdobj.nderiv;
wfdcell = Lfdobj.bwtcell;
afdcell = Lfdobj.awtcell;
k       = length(afdcell);
nplot   = m + k;
for j=1:m
    subplot(nplot,1,j)
    plot(wfdcell{j})
    xlabel('')
    ylabel(['\fontsize{16}\beta_',num2str(j-1),'(t)'])
end
for j=1:k
    subplot(nplot,1,m+j)
    plot(afdcell{j})
    xlabel('')
    ylabel(['\fontsize{16}\alpha_',num2str(j),'(t)'])
end