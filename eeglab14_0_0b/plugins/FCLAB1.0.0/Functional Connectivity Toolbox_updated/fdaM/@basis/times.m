function prodbasisobj = times(basisobj1, basisobj2)
% TIMES for two basis objects sets up a basis suitable for 
%  expanding the pointwise product of two functional data
%  objects with these respective bases.  
% In the absence of a true product basis system in this code,
%  the rules followed are inevitably a compromise:
%  (1) if both bases are B-splines, the norder is the sum of the
%      two orders - 1, and the knots are the union of the
%      two sets of knots.  This is clearly a compromise that
%      will not work properly in some situations.  For example,
%      this produces a spline that is more differentiable than
%      either factor spline.  
%      In the case where one of the splines is order 1, or a step
%      function, the problem is dealt with by replacing the
%      original knot values by multiple values at that location
%      to give a discontinuous derivative.
%  (2) if both bases are Fourier bases, AND the periods are the 
%      the same, the product is a Fourier basis with number of
%      basis functions the sum of the two numbers of basis fns.
%  (3) if only one of the bases is B-spline, the product basis
%      is B-spline with the same knot sequence and order two
%      higher.
%  (4) in all other cases, the product is a B-spline basis with
%      number of basis functions equal to the sum of the two
%      numbers of bases and equally spaced knots.  

%  Of course the ranges must also match.

%  Last modified 12 December 2006

%  check the ranges

range1 = getbasisrange(basisobj1);
range2 = getbasisrange(basisobj2);
if range1(1) ~= range2(1) || range1(2) ~= range2(2)
    error('Ranges are not equal.');
end

%  get the types

type1 = getbasistype(basisobj1);
type2 = getbasistype(basisobj2);

%  deal with constant bases

if strcmp(type1, 'const') && strcmp(type2, 'const')
    prodbasisobj = create_constant_basis(range1);
    return;
end

if strcmp(type1, 'const')
    prodbasisobj = basisobj2;
    return;
end

if strcmp(type2, 'const')
    prodbasisobj = basisobj1;
    return;
end

%  get the numbers of basis functions

nbasis1 = getnbasis(basisobj1);
nbasis2 = getnbasis(basisobj2);

%  work through the cases

if strcmp(type1, 'bspline') && strcmp(type2, 'bspline')
    %  both bases are B-splines
    %  get orders
    interiorknots1 = getbasispar(basisobj1);
    interiorknots2 = getbasispar(basisobj2);
    norder1 = nbasis1 - length(interiorknots1);
    norder2 = nbasis2 - length(interiorknots2);
    if norder1 == 1 || norder2 == 1
        %  one of the bases is of order 1.
        %  exchange if it isn't the second
        if norder1 == 1
            tempbasis = basis(basisobj2);
            basisobj1 = basis(tempbasis);
        end
        norder = norder1;
        interiorknots = getbasispar(basisobj1);
        breaks = interiorknots;
        for iorder=2:norder
            breaks = [breaks, interiorknots];
        end
        breaks = [range1(1), sort(breaks), range1(2)];
    else
        %  both bases have orders greater than 1
        norder  = norder1 + norder2 - 1;
        %  collect all knots together
        allbreaks  = [range1(1), ...
                sort([interiorknots1, interiorknots2]), ...
                range1(2)];
        %  keep only unique values
        breaks = unique(allbreaks);
    end
    nbasis = length(breaks) + norder - 2;
    prodbasisobj = ...
        create_bspline_basis(range1, nbasis, norder, breaks);
    return;
end

if strcmp(type1, 'fourier') && strcmp(type2, 'fourier')
    %  both bases Fourier
    %  check whether periods match
    %  if they do not, default to the basis below.
    period1 = getbasispar(basisobj1);
    period2 = getbasispar(basisobj2);
    nbasis  = nbasis1 + nbasis2;
    if period1 == period2
        prodbasisobj = ...
            create_fourier_basis(range1, nbasis, period1);
        return;
    end
end

%  default case when all else fails: the product basis is B-spline 
%  When neither basis is a B-spline basis, the order
%  is the sum of numbers of bases, but no more than 8.
%  When one of the bases if B-spline and the other isn't,
%  the order is the smaller of 8 or the order of the spline
%  plus 2.

if strcmp(type1, 'bspline') || strcmp(type2, 'bspline')
    norder = 8;
    if strcmp(type1, 'bspline') 
        interiorknots1 = getbasispar(basisobj1);
        norder1 = nbasis1 - length(interiorknots1);
        norder = min(norder1+2, norder);
    end
    if strcmp(type2, 'bspline') 
        interiorknots2 = getbasispar(basisobj2);
        norder2 = nbasis2 - length(interiorknots2);
        norder = min(norder2+2, norder);
    end
else
    %  neither basis is B-spline
    norder = min(8, nbasis1+nbasis2);
end
%  set up the default B-spline product basis
nbasis = max(nbasis1+nbasis2, norder+1);
prodbasisobj = create_bspline_basis(range1, nbasis, norder);