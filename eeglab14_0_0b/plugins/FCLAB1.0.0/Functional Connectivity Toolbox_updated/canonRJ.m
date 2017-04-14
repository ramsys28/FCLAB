function [R,J]=canonRJ(t,k) %x is the time; k is number of knots
bsl=create_bspline_basis([min(t),max(t)],k,4);  %k is the number of basis 
R=bsplinepen(bsl,int2Lfd(2),[min(t),max(t)],1);
J=bsplinepen(bsl,int2Lfd(0),[min(t),max(t)],1);
end