function alpha=parameter(t,x,k)
bsl=create_bspline_basis([min(t),max(t)],k,4);  %k+2 is the number of basis 
[fdobj, df, gcv, coef] =smooth_basis(t,x, bsl);
alpha=coef;
end