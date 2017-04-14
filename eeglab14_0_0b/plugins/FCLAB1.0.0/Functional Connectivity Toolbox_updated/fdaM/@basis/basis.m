function basisobj = basis(basistype, rangeval, nbasis, params, ...
                          dropind, quadvals, values)
%  BASIS  Creates a functional data basis.
%  Arguments:
%  BASISTYPE ... a string indicating the type of basis.  This may be one of
%               'Fourier', 'fourier', 'Fou', 'fou',
%               'Bspline', 'bspline', 'Bsp', 'bsp',
%               'pol', 'poly', 'polynomial',
%               'mon', 'monom', 'monomial',
%               'con', 'const', 'constant'
%               'exp', 'exponen', 'exponential'
%               'polyg' 'polygon', 'polygonal'
%  RANGEVAL ... an array of length 2 containing the lower and upper
%               boundaries for the rangeval of argument values
%  NBASIS   ... the number of basis functions
%  PARAMS   ... If the basis is 'fourier', this is a single number indicating
%                 the period.  That is, the basis functions are periodic on
%                 the interval (0,PARAMS) or any translation of it.
%               If the basis is 'bspline', the values are interior points at
%                 which the piecewise polynomials join.
%                 Note that the number of basis functions NBASIS is equal
%                 to the order of the Bspline functions plus the number of
%                 interior knots, that is the length of PARAMS.
%               This means that NBASIS must be at least 1 larger than the
%                 length of PARAMS.
%  DROPIND ... A set of indices in 1:NBASIS of basis functions to drop
%                when basis objects are arguments.  Default is [];  Note
%                that argument NBASIS is reduced by the number of indices,
%                and the derivative matrices in VALUES are also clipped.
%  QUADVALS .. A NQUAD by 2 matrix.  The first column contains quadrature
%                points to be used in a fixed point quadrature.  The second
%                contains quadrature weights.  For example, for Simpson's 
%                rule for NQUAD = 7, the points are equally spaced and the 
%                weights are delta.*[1, 4, 2, 4, 2, 4, 1]/3.  DELTA is the
%                spacing between quadrature points.  The default is [].
%  VALUES  ... A cell array, with entries containing the values of
%                the basis function derivatives starting with 0 and
%                going up to the highest derivative needed.  The values
%                correspond to quadrature points in QUADVALS and it is
%                up to the user to decide whether or not to multiply
%                the derivative values by the square roots of the 
%                quadrature weights so as to make numerical integration
%                a simple matrix multiplication.   
%                Values are checked against QUADVALS to ensure the correct
%                number of rows, and against NBASIS to ensure the correct
%                number of columns.
%                The default is VALUES{1} = [];
%  Returns
%  BASISOBJ  ... a basis object with slots
%         type
%         rangeval
%         nbasis
%         params
%         dropind
%         quadvals
%         values
%  Slot VALUES contains values of basis functions and derivatives at
%   quadrature points weighted by square root of quadrature weights.
%   These values are only generated as required, and only if slot
%   quadvals is not empty.
%
%  An alternative name for this function is CREATE_BASIS, but PARAMS argument
%     must be supplied.
%  Specific types of bases may be set up more conveniently using functions
%  CREATE_BSPLINE_BASIS    ...  creates a b-spline basis
%  CREATE_FOURIER_BASIS    ...  creates a fourier basis
%  CREATE_POLYGON_BASIS    ...  creates a polygonal basis
%  CREATE_MONOM_BASIS      ...  creates a monomial basis
%  CREATE_POLYNOMIAL_BASIS ...  creates a polynomial basis
%  CREATE_CONSTANT_BASIS   ...  creates a constant basis

%  last modified 26 July 2006

if nargin==0
    basisobj.type      = 'bspline';
    basisobj.rangeval  = [0,1];
    basisobj.nbasis    = 2;
    basisobj.params    = [];
    basisobj.dropind   = [];
    basisobj.quadvals  = [];
    basisobj.values{1} = [];
    basisobj = class(basisobj, 'basis');
    return;
end

if nargin < 4
    error('Less than four arguments found.');
end

%  if first argument is a basis object, return

if isa(basistype, 'basis')
    basisobj = basistype;
    return;
end

%  check basistype

basistype = use_proper_basis(basistype);
if strcmp(basistype,'unknown')
    error ('TYPE unrecognizable.');
end

%  check if QUADVALS is present, and set to default if not

if nargin < 6
    quadvals = [];
else
    if ~isempty(quadvals)
        [nquad,ncol] = size(quadvals);
        if nquad == 2 && ncol > 2
            quadvals = quadvals';
            [nquad,ncol] = size(quadvals);
        end
        if nquad < 2
            error('Less than two quadrature points are supplied.');
        end
        if ncol ~= 2
            error('QUADVALS does not have two columns.');
        end
    end
end

%  check VALUES if present, and set to a single empty cell
%  if not.

if nargin < 7
    values{1} = [];
else
    if ~iscell(values)
        error('VALUES argument is not a cell array.');
    end
    if ~isempty(values{1})
        nvalues = length(values);
        for ivalue=1:nvalues
            [n,k] = size(full(values{ivalue}));
            if n ~= nquad
                error(['Number of rows in VALUES not equal to ', ...
                        'number of quadrature points.']);
            end
            if k ~= nbasis
                error(['Number of columns in VALUES not equal to ', ...
                        'number of basis functions.']);
            end
        end
    end
end

%  check if DROPIND is present, and set to default if not

if nargin < 5
    dropind = [];
else  
    if ~isempty(dropind)
        %  check DROPIND
        ndrop = length(dropind);
        if ndrop >= nbasis
            error('Too many index values in DROPIND.');
        end
        dropind = sort(dropind);
        if ndrop > 1
            if any(diff(dropind)) == 0
                error('Multiple index values in DROPIND.');
            end
        end
        for i=1:ndrop;
            if dropind(i) < 1 || dropind(i) > nbasis
                error('An index value is out of range.');
            end
        end
        %  drop columns from VALUES cells if present
        droppad = [dropind,zeros(1,nbasis-ndrop)];
        keepind = (1:nbasis) ~= droppad;
        if ~isempty(values) && ~isempty(values{1})
            for ivalue=1:nvalues
                derivvals = values{ivalue};
                derivvals = derivvals(:,keepind);
                values{ivalue} = derivvals;
            end
        end
    end
end

%  select the appropriate type and process

switch basistype
    case 'fourier'
        period     = params(1);
        if (period <= 0)
            error ('Period must be positive for a Fourier basis');
        end
        params = period;
        if (2*floor(nbasis/2) == nbasis)
            nbasis = nbasis + 1;
        end
        
    case 'bspline'
        if ~isempty(params)
            nparams  = length(params);
            if (params(1) <= rangeval(1))
                error('Smallest value in BREAKS not within RANGEVAL');
            end
            if (params(nparams) >= rangeval(2))
                error('Largest value in BREAKS not within RANGEVAL');
            end
        end
        
    case 'expon'
        if (length(params) ~= nbasis)
            error(['No. of parameters not equal to no. of basis fns ',  ...
                    'for exponential basis.']);
        end
        
    case 'polyg'
        if (length(params) ~= nbasis)
            error(...
                'No. of parameters not equal to no. of basis fns for polygonal basis.');
        end
        
    case 'power'
        if length(params) ~= nbasis
            error(...
                'No. of parameters not equal to no. of basis fns for power basis.');
        end
        
    case 'const'
        params = 0;
        
    case 'monom'
        if length(params) ~= nbasis
            error(['No. of parameters not equal to no. of basis fns', ...
                   ' for monomial basis.']);
        end
        
    case 'polynom'
        if length(params) > 1
            error('More than one parameter for a polynomial basis.');
        end
        
    otherwise
        error('Unrecognizable basis');
end

basisobj.type      = basistype;
basisobj.rangeval  = rangeval;
basisobj.nbasis    = nbasis;
basisobj.params    = params;
basisobj.dropind   = dropind;
basisobj.quadvals  = quadvals;
basisobj.values    = values;

basisobj = class(basisobj, 'basis');

%  ------------------------------------------------------------------------

function fdtype = use_proper_basis(fdtype)
%  USE_PROPER_BASIS recognizes type of basis by use of several variant spellings

%  Last modified 24 October 2003

switch fdtype
    
    case 'Fourier'
        fdtype = 'fourier';
    case 'fourier'
        fdtype = 'fourier';
    case 'Fou'
        fdtype = 'fourier';
    case 'fou'
        fdtype = 'fourier';
        
    case 'bspline'
        fdtype = 'bspline';
    case 'Bspline'
        fdtype = 'bspline';
    case 'Bsp'
        fdtype = 'bspline';
    case 'bsp'
        fdtype = 'bspline';
        
    case 'power'
        fdtype = 'power';
    case 'pow'
        fdtype = 'power';
        
    case 'polyg'
        fdtype = 'polyg';
    case 'polygon'
        fdtype = 'polyg';
    case 'polygonal'
        fdtype = 'polyg';
        
    case 'exp'
        fdtype = 'expon';
    case 'expon'
        fdtype = 'expon';
    case 'exponential'
        fdtype = 'expon';
        
    case 'con'
        fdtype = 'const';
    case 'const'
        fdtype = 'const';
    case 'const'
        fdtype = 'const';
        
    case 'mon'
        fdtype = 'monom';
    case 'monom'
        fdtype = 'monom';
    case 'monomial'
        fdtype = 'monom';
        
    case 'poly'
        fdtype = 'polynom';
    case 'polynom'
        fdtype = 'polynom';
    case 'polynomial'
        fdtype = 'polynom';
        
    otherwise
        fdtype = 'unknown';
        
end
