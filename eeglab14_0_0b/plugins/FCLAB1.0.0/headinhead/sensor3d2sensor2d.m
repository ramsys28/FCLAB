   function s2d=sensor3d2sensor2d(sensors,lr,ud);   
   

   [ns,ndum]=size(sensors);
   [center,radius]=sphfit(sensors);
   s=sensors-repmat(center,ns,1);
   cms=mean(sensors);
   zz=cms-center;
   zz=zz/norm(zz);
   snorms=sqrt(sum((s').^2)');
   s=s./repmat(snorms,1,3);
   thetas=acos( s*zz');
   ex=[1;0;0];ey=[0;1;0];
   yy=cross(zz',ex);yy=yy/norm(yy);
   xx=cross(yy,zz');xx=xx/norm(xx);
   xx=xx';
   yy=yy';
   
   xxx=s*xx';
   yyy=s*yy';
   
   phis=angle(xxx+sqrt(-1)*yyy);
   
   locs=[cos(phis).*thetas,sin(phis).*thetas];
   
   if nargin>1 
       if lr==1
           locs=[-locs(:,1),locs(:,2)];
       end
   end
   
   if nargin>2 
       if ud==1
           locs=[locs(:,1),-locs(:,2)];
       end
   end

   locs=locs/max(max(abs(locs)))/2;
   
   
   
   
   s2d=locs;
   
   return; 
   
   
   
   
   