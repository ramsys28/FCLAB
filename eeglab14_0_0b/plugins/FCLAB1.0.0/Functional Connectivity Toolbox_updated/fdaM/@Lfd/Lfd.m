function Lfdobj = Lfd(m, bwtcell, awtcell, ufdcell)
%  LFD creates a linear differential operator object of the form
%
%  Lx(t) = w_0(t) x(t) + ... + w_{m-1}(t) D^{m-1}x(t) + 
%          \exp[w_m(t) D^m x(t) + ...
%          a_1(t) u_1(t)  + ... + a_k(t) u_k(t).
%  
%  Function x(t) is operated on by this operator L, and the operator
%  computes a linear combination of the function and its first m
%  derivatives.  The function x(t) must be scalar.  This part
%  part of the operator (the first two lines in the above equation)
%  is called the HOMOGENEOUS part of the operator.
%
%  The linear combination of derivatives is defined by the weight 
%  or coefficient functions w_j(t), and these are assumed to vary  
%  over t, although of course they may also be constant as a 
%  special case.  
%
%  The weight coefficient for D^m is special in that it must
%  be positive to properly identify the operator.  This is why
%  it is exponentiated.  In most situations, it will be 0,
%  implying a weight of one, and this is the default.  
%
%  The operator $L$ is potentially defined by one or more known
%  scalar forcing functions u_1(t), ..., u_k(t), each multiplied by  
%  a weight or coefficient function a(t).  If the forcing functions
%  are defined, then the operator is called NONHOMOGENEOUS, and the
%  nonhomogenous part of the operator is the third lined in the 
%  above equation.
%
%  It may be required that within any of these three groups the 
%  functions will vary in complexity.  Consequently, each group
%  is input to constructor function Lfd() as a cell object, and
%  each individual function within the group is defined within
%  a cell member.
%  
%  The evaluation of the linear differential operator L is applied to 
%  basis functions takes place in function EVAL_BASIS().  Here only 
%  the homogeneous part of the operator is used, defined in WFDCELL.

%  The evaluation of the linear differential operator L applied to
%  functional data objects takes placed in function EVAL_FD(). Here
%  the entire operator is applied, including any forcing functions
%  defined in UFDCELL and weighted by AFDCELL.
%
%  The inner products of the linear differential operator L 
%  applied to basis functions is evaluated in the functions
%  called in function EVAL_PENALTY().  Here only the homogeneous part 
%  of the operator is used, defined in WFDCELL.
%
%  Some important functions also have the capability of allowing
%  the argument that is an LFD object be an integer. They convert 
%  the integer internally to an LFD object by INT2LFD().  These are:
%     EVAL_FD()
%     EVAL_MON()
%     EVAL_POS()
%     EVAL_BASIS()
%     EVAL_PENALTY()
%
%  Arguments:
%
%  M       ... the order of the operator, NDERIV, that is,
%          the highest order of derivative.
%  BWTCELL ... A cell vector object with either m or m+1 cells.
%          If there are m cells, then the coefficient of D^m
%          is set to 1; otherwise, cell m+1 contains a function
%          that is exponentiated to define the actual coefficient.
%  AWTCELL ... A cell vector object with k cells,
%          where k is the number of forcing functions.  
%          k may be zero, in which case AWTCELL will be an empty cell,
%          and this is the default if AWTCELL is not supplied.
%  UFDCELL ... A cell vector containing the forcing functions.
%          If UFDCELL is not supplied but AWTCELL is, then the 
%          default is the unit function using the constant basis.
%
%  Simple cases: 
%
%  All this generality may not be needed, and, for example, 
%  often the linear differential operator will be 
%  simply L = D^m, defining Lx(t) = D^mx(t).  Or the weights and 
%  forcing functions may all have the same bases, in which case 
%  it is simpler to use a functional data objects to define them.  
%  These situations cannot be accommodated within Lfd(), but
%  there is function int2Lfd(m) that converts a nonnegative 
%  integer m into an Lfd object equivalent to D^m. 
%  There is also fd2cell(fdobj) and that converts a functional 
%  data object into cell object, which can then be used as
%  an argument of Lfd().
%
%  Returns:
%
%  LFDOBJ ... a functional data object

%  last modified 25 July 2006

if nargin > 2
    warning(['Use of Lfd for nonhomogeneous operators ', ...
             'to be discontinued.']);
end

%  check m

if ~isnumeric(m)
    error('Order of operator is not numeric.');
end
if m ~= round(m)
    error('Order of operator is not an integer.');
end
if m < 0
    error('Order of operator is negative.');
end

%  check that BWTCELL is a cell object

if ~iscell(bwtcell)
    error('BWTCELL not a cell object.');
end

if isempty(bwtcell)
    if m > 0
        error(['Positive derivative order accompanied by ', ...
               'empty weight cell.']);
    end
else
    bwtsize = size(bwtcell);
    bfdPar  = bwtcell{1};
    bfd     = getfd(bfdPar);
    brange  = getbasisrange(getbasis(bfd));
    bnames  = getnames(bfd);    
    
    %  BWTCELL two-dimensional.  
    %  Only possibilities are (1) N > 1, M = 1, and 
    %                         (2) N = 1, M >= 1;
    if length(bwtsize) == 2
        if bwtsize(1) > 1 &&  bwtsize(2) > 1
            error('BWTCELL is not a vector.');
        else
            if m > 0
                if bwtsize(1) ~= m && bwtsize(2) ~= m
                    error('Dimension of BWTCELL not compatible with M.');
                end
            end
        end
    end
    
    %  BWTCELL has more than two dimensions. 
    
    if length(bwtsize) > 2
        error('BWTCELL has more than two dimensions.');
    end
    
    %  Check the ranges for compatibility
    
    for j=2:m
        brangej  = getbasisrange(getbasis(getfd(bwtcell{j})));
        if any(brangej ~= brange)
            error('Incompatible ranges in weight functions.');
        end
    end

    
end

%  check AWTCELL

if nargin >= 4 && ~isempty(ufdcell) 
    if ~iscell(awtcell)
        error('AWTCELL is not a cell object.');
    end
    if ~isempty(awtcell)
        awtsize = size(awtcell);
        if length(awtsize) > 3
            error('AWTCELL has more than two dimensions');
        end
        if length(awtsize) == 2
            if awtsize(1) > 1 && awtsize(2) > 1
                error('AWTCELL has both dimensions greater than one.');
            end
            if awtsize(1) == 1
                k = awtsize(2);
            else
                k = awtsize(1);
            end
            for j=1:k
                afdParj = awtcell{j};
                afdj    = getfd(afdParj);
                arange  = getbasisrange(getbasis(afdj));
                if any(arange ~= brange)
                    error('BRANGE and ARANGE do not match.');
                end
                acoef = getcoef(afdj);
                if ~size(acoef,2) == 1
                    error('AWTCELL is not a single function');
                end
            end
        end
    end
else
    awtcell = {};
end

%  set up the default unit functions for UFDCELL

if nargin == 3      
    ubasis = create_constant_basis(brange);
    unames = bnames;
    unames{2} = 'forcing fn.';
    unames{3} = [bnames{3}, 'forcing fn.'];
    ufd = fd(1, ubasis, unames);
    for i=1:k
        ufdcell{i} = ufd;
    end
end

%  check UFDCELL

if nargin >= 4 && ~isempty(awtcell)
    if ~iscell(ufdcell)
        error('UFDCELL is not a cell object.');
    end
    %  check each cell of UFDCELL
    if ~isempty(ufdcell)
        for i=1:k
            ubasis = getbasis(ufdcell{i});
            urange = getbasisrange(ubasis);
            if any(urange ~= brange)
                error('WRANGE and URANGE do not match for a UFDCELL.');
            end
            ucoef = getcoef(ufdcell{i});
            if ~size(ucoef,2) == 1
                error('A UFDCELL is not a single function');
            end
        end
    end
else
    ufdcell = {};
end

%  set up the Lfd object

Lfdobj.nderiv  = m;
Lfdobj.bwtcell = bwtcell;
Lfdobj.awtcell = awtcell;
Lfdobj.ufdcell = ufdcell;

Lfdobj = class(Lfdobj, 'Lfd');

