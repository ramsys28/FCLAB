function display(fdParobj)

%  Last modified 20 July 2006

fprintf('\nFD:\n');
display(fdParobj.fd);
nderiv = getnderiv(fdParobj.Lfd);
if nderiv > 0
    fprintf('\nLFD:\n\n');
    display(fdParobj.Lfd);
else
    fprintf('\nLFD      = 0');
end
fprintf('\n\nLAMBDA   = %.6g', fdParobj.lambda);
fprintf('\nESTIMATE = %d',   fdParobj.estimate);
if ~isempty(fdParobj.penmat)
    fprintf('\n\nPENALTY MATRIX\n');
    disp(fdParobj.penmat)
end

