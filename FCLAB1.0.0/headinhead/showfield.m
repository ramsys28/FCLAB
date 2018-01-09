function showfield(z,loc,pars); 
% makes plots of potentials on head
% usage showfield(z,loc,pars);
%
% input:
%  z  values of field/potential to be shown.
%  loc   matrix containing 2D coordinates of channels in second and third column 
% pars is optional
% pars.scale sets the scale of the color map. Either a 1x2 vector
%            corresponding to minimum and a maximum or just a number (say x) 
%            then the scale is from [-x x]. The default is 
%            scale=[ -max(abs(z)) max(abs(z)) ]
% pars.resolution sets the resolution, default is 100
%  pars.cbar=1 draws colorbar, otherwiseno colorbar is not shown. 
%              defaults is 1;

scal=[-max(max(abs(z))),max(max(abs(z)))];
cbar=1;
resolution=100;


if nargin>2
    if isfield(pars,'scale')
        scal=pars.scale;
        if length(scal)==1
            scal=[-scal scal];
        end
    end
    if isfield(pars,'cbar')
       cbar=pars.cbar;
    end
    if isfield(pars,'colorbar')
       cbar=pars.colorbar;
    end
    if isfield(pars,'resolution')
       resolution=pars.resolution;
    end
 
end



[n,m]=size(loc);
if m==2;
  x=loc(:,1);
  y=loc(:,2);
else;
  x=loc(:,2);
  y=loc(:,3);
end


xlin = linspace(1.4*min(x),1.4*max(x),resolution);
ylin = linspace(1.4*min(y),1.4*max(y),resolution);
[X,Y] = meshgrid(xlin,ylin);
Z = griddata(x,y,z,X,Y,'invdist');
%Z = griddata(x,y,z,X,Y,'nearest');


  % Take data within head
  rmax=1.02*max(sqrt(x.^2+y.^2));
  mask = (sqrt(X.^2+Y.^2) <= rmax);
  ii = find(mask == 0);
  Z(ii) = NaN;
  
  
surface(X,Y,zeros(size(Z)),Z,'edgecolor','none');shading interp;
%caxis([ - max(abs(z)) max(abs(z))]);
caxis(scal);
hold on;
plot(x,y,'.k','markersize',2);


%meanx=mean(loc(:,2)*.85+.45);
%meany=mean(loc(:,3)*.85+.45);
scalx=1;
drawhead(0,.0,rmax,scalx);
set(gca,'visible','off');

axis([-1.2*rmax 1.2*rmax -1.0*rmax 1.4*rmax]);
axis equal;
%axis([-1.4*rmax 1.4*rmax -1.0*rmax 1.4*rmax]);
if cbar==1
  h=colorbar;set(h,'fontweight','bold')
  %P=get(h,'Position');P(1)=P(1)+.1;
  %set(h,'Position',P);
end

%plot(.985*rmax*sin((0:1000)/1000*2*pi), .985*rmax*cos((0:1000)/1000*2*pi),'linewidth',2,'color','k'); 
return; 



function drawhead(x,y,size,scalx);

cirx=(x+scalx*size*cos((1:1000)*2*pi/1000) )';ciry=(y+size*sin((1:1000)*2*pi/1000))';

plot(cirx,ciry,'k','linewidth',1);
hold on;

ndiff=20;
plot( [x  cirx(250-ndiff) ],[y+1.1*size ciry(250-ndiff)],'k','linewidth',1);
plot( [x  cirx(250+ndiff) ],[y+1.1*size ciry(250+ndiff)],'k','linewidth',1);


return;
