function outEEG = fcmetric_iCOH(inEEG) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%
%   >>  outEEG = fcmetric_iCOH(inEEG);
%
% Inputs:
%           inEEG  - input EEG dataset
%   
%    
% Outputs:
%           outEEG  - output dataset
%
% Info:
%           Computes the magnitude square coherence for each possible pair 
%           of EEG channels and for every band as well.
%
% Mathematical background:
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mf = size(inEEG.FC.parameters.bands,1);
outEEG = inEEG;
disp('>> FCLAB: iCOH is being computed...');


k=1;
for i=1:mf
    top_freqs(k)=max(str2num(inEEG.FC.parameters.bands{i,1}));
    k=k+1;
end;
max_freq=max(top_freqs)+1;

if length(size(inEEG.data))==2
    para.subave=0;
    [cs,coh,nave]=data2cs_event(inEEG.data',inEEG.srate,round(inEEG.srate/2),max(size(inEEG.data)),max_freq,para);
else
    [cs,coh,nave]=data2cs_event(inEEG.data',inEEG.srate,round(inEEG.srate/2),max(size(inEEG.data)),max_freq);
end;

for i = 1:mf

eval(['outEEG.FC.iCOH.'...
             strrep(inEEG.FC.parameters.bands{i,2},' ','_') ...
             '.adj_matrix=imag(mean(coh(:,:,' int2str(round(min(str2num(inEEG.FC.parameters.bands{i,1})))) ':'...
             int2str(max(str2num(inEEG.FC.parameters.bands{i,1}))) '),3));']);

end