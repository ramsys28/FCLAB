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
[cs,coh,nave]=data2cs_event(EEG.data',EEG.srate,EEG.srate,max(size(EEG.data)),40,para);