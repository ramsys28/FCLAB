function nderiv = getnderiv(Lfdobj)
%  GETNDERIV   Extracts the order of the operator from LFDOBJ.

%  last modified 2 January 2003

if ~isa_Lfd(Lfdobj)
    error('Argument is not a linear differential operator object');
end

nderiv = Lfdobj.nderiv;


