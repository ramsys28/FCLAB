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
disp('>> FCLAB: MSC is being computed...');
if length(size(EEG.data))==3
    para.subave=0
    [cs,coh,nave]=data2cs_event(EEG.data',EEG.srate,round(EEG.srate/2),max(size(EEG.data)),41,para);
else
    [cs,coh,nave]=data2cs_event(EEG.data',EEG.srate,round(EEG.srate/2),max(size(EEG.data)),41);
end;