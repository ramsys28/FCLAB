basisobj1 = create_bspline_basis([0,1],5);
basisobj2 = create_bspline_basis([0,1],6);
coef1 = randn(5,1);
coef2 = randn(6,1);
fdnames = cell(3,1);
fdnames{1} = 'Time';
fdnames{2} = 'Reps';
fdnames1 = fdnames;
fdnames1{3} = 'f1';
fdobj1 = fd(coef1, basisobj1, fdnames1);
fdnames2 = fdnames;
fdnames2{3} = 'f2';
fdobj2 = fd(coef2, basisobj2, fdnames2);

figure(1)
subplot(2,1,1)
plot(fdobj1)
subplot(2,1,2)
plot(fdobj2)

fdprodobj = fdobj1.*fdobj2;

figure(2)
subplot(1,1,1)
plot(fdprodobj)

prodbasisobj = getbasis(fdprodobj);
prodbasisobj

figure(3)
plot(getbasis(fdprodobj))

coef1 = randn(5,N);
fdobj1 = fd(coef1, basisobj1, fdnames1);

fac = 2*ones(10,1);
fac = randn(10,1);

fdprodobj = fdobj1.*fac;

figure(1)
subplot(1,1,1)
plot(fdobj1)

figure(2)
subplot(1,1,1)
plot(fdprodobj)

N = 20;

conbas = create_constant_basis([0,1]);
confd  = fd(ones(1,N),conbas);

basisobj2 = create_bspline_basis([0,1],5);
basisobj3 = create_bspline_basis([0,1],6);

coef2 = randn(5,N);
xobj2 = fd(coef2, basisobj2, fdnames1);
coef3 = randn(6,N);
xobj3 = fd(coef3, basisobj3, fdnames2);

yfd = confd + 2.*xobj2 - 2.*xobj3;

ybasis = getbasis(yfd);

plot(ybasis)

xfdcell = cell(1,3);
xfdcell{1} = confd;
xfdcell{2} = xobj2;
xfdcell{3} = xobj3;

betacell = cell(1,3);

betacell{1} = fdPar(conbas);
betacell{2} = fdPar(conbas);
betacell{3} = fdPar(conbas);

yfdPar = fdPar(yfd);

fRegressCell = fRegress(yfdPar, xfdcell, betacell);

betaestcell = fRegressCell{4};

for i=1:3
    subplot(3,1,i)
    plot(getfd(betaestcell{i}))
end

betabasis = create_bspline_basis([0,1],4);
betafd1 = fd(1, conbas);
betacell{1} = fdPar(betafd1);
for j=2:3
    betafdj = fd(randn(4,1),betabasis);
    betacell{j} = fdPar(betafdj);
end

yfd0 = getfd(betacell{1}) + ...
       getfd(betacell{2}).*xfdcell{2} + ...
       getfd(betacell{3}).*xfdcell{3};
ybasis = getbasis(yfd0);
ynbasis = getnbasis(ybasis);

sigma = 0.1;
efd = fd(randn(ynbasis,N).*sigma, ybasis);
yfd = yfd0 + efd;

yfdPar = fdPar(yfd);

fRegressCell = fRegress(yfdPar, xfdcell, betacell);

betaestcell = fRegressCell{4};

tfine = linspace(0,1,101)';
for j=1:3
    subplot(3,1,j)
    plot(tfine, eval_fd(tfine,getfd(betaestcell{j})), '-', ...
         tfine, eval_fd(tfine,getfd(   betacell{j})), '--')
end
