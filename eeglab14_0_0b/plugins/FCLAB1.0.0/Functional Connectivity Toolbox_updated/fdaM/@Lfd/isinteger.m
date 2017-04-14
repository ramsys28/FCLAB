function intwrd = isinteger(Lfdobj)
% ISINTEGER returns 1 of WFD and AFD are both zero functions.

%  Last modified 5 November 2003

%  check WFDCELL for emptyness or all zero

wfdcell = getwfdcell(Lfdobj);
wintwrd = 1;
if ~isempty(wfdcell)
    nderiv = Lfdobj.nderiv;
    for j=1:nderiv
        wfdParj = wfdcell{j};
        wfdj    = getfd(wfdParj);
        if any(getcoef(wfdj) ~= 0.0)
            wintwrd = 0;
        end
    end
end

%  check AFDCELL for emptyness or all zero

afdcell = getafdcell(Lfdobj);
aintwrd = 1;
if ~isempty(afdcell)
    k = max(size(afdcell));
    for i=1:k
        afdPari = afdcell{i};
        afdi    = getfd(afdPari);
        if any(getcoef(afdi) ~= 0.0)
            aintwrd = 0;
        end
    end
end

intwrd = wintwrd & aintwrd;