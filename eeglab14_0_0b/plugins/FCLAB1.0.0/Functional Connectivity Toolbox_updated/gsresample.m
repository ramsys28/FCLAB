function[scaledata]=gsresample(data,origHz,newHz)
% rescales vector data from origHz to newHz
% Useage: resample(data,origHz,newHz)
if size(data,2)==1, data=data'; end;

if newHz<origHz
  downscalefactor=newHz./origHz;
  if(downscalefactor<=.5)
    ptstoskip=round (1./downscalefactor);
    filterindex=fix( (1./downscalefactor)./2)-1;
%    newlen=round(size(data,2)./ptstoskip);
    newlen=round((size(data,2).*newHz)./origHz);
    scaledata=zeros(1,newlen);

    midindices=linspace(1,length(data),newlen+2);
    indtouse=floor(midindices(2:(newlen+1)));
    winsize=floor(indtouse(1)./2);
    
    for i=1:newlen
      scaledata(i)=mean(data((indtouse(i)-winsize):(indtouse(i)+winsize)));
    end
  else
    indices=linspace(1,length(data),downscalefactor.*length(data));
    for ct=1:newHz
      scaledata(ct)=mean([data(floor(indices(ct))) data(ceil(indices(ct)))]);
    end
  end
else
  newsize=round(length(data).*newHz./origHz);
  scaledata=zeros(1,newsize);
  for ct=1:newsize
    scaledata(ct)=data(max(1,round(ct.*(origHz./newHz))));
  end
  %fprintf(1,'newHz must not exceed origHz\n');
  %return;
end
