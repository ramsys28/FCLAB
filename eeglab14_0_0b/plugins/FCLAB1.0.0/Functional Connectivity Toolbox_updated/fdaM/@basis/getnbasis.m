function nbasis = getnbasis(basisobj)
%  GETNBASIS   Extracts the type of basis from basis object BASISOBJ.

%  last modified 30 June 1998

  if ~isa_basis(basisobj)
    error('Argument is not a functional basis object.');
  end

  nbasis = basisobj.nbasis;
