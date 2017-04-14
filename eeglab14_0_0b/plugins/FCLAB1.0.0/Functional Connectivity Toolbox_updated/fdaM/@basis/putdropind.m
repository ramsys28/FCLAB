function basisobj = putdropind(basisobj, dropind)
%  PUQUADVALS   Enters drop indices for
%     basis object BASISOBJ into slot basisobj.dropind

%  last modified 20 July 2006

if ~isa_basis(basisobj)
    error('Argument is not a functional basis object.');
end

%  check DROPIND

if length(dropind) >= basisobj.nbasis
    error('Too many index values in DROPIND.');
end
dropind = sort(dropind);
if length(dropind) > 1
    if any(diff(dropind)) == 0
        error('Multiple index values in DROPIND.');
    end
end
for i=1:length(dropind);
    if dropind(i) < 1 || dropind(i) > basisobj.nbasis
        error('An index value is out of range.');
    end
end

basisobj.dropind = dropind;
