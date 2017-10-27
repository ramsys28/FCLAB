function outEEG = fcmetric_iCOH(inEEG) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%
%   >>  outEEG = fcmetric_iCOH(inEEG);
%
% Input(s):
%           inEEG   - input EEG dataset
%    
% Output(s):
%           outEEG  - output EEG dataset
%
% Info:
%           Computes the imaginary part of coherence for each possible pair 
%           of EEG channels and for every band as well.
%
% Mathematical background:
%           For two signals, assume x, y, the magnitude squared coherence 
%           at frequency f, |R(f)|^2, can be defined as follows:
%
%                           iCOH = imagin(|R(f)|)
%
%           where R(f) is the coherency and its magnitude, |R(f)| is the
%           coherence of signals x, y at frequency f.
%
% Fundamental basis:
%           The imaginary part of coherence (iCOH) is insensitive to 
%           artefactual ‘self-interaction’ caused by volume conduction 
%           because a signal is not time-lagged to itself and thus manages 
%           to identify the synchronizations of two signals which are time-
%           lagged. 
%
% Reference(s):
%           Sander T.H., Bock A., Leistner S., Kuhn A., and Trahms
%           L.(2010). Coherence and imaginary part of coherency identifies 
%           cortico-muscular and cortico-thalamic coupling. Conf Proc IEEE 
%           Eng Med Biol Soc. 2010, 1714-1717
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mf = size(inEEG.FC.parameters.bands,1);
outEEG = inEEG;
disp('>> FCLAB: iCOH is being computed...');

k=1;
for i=1:mf
    top_freqs(k)=max(str2num(inEEG.FC.parameters.bands{i,1}));
    k=k+1;
end
max_freq=max(top_freqs)+1;

if length(size(inEEG.data))==2
    para.subave=0;
    [cs,coh,nave]=data2cs_event(inEEG.data',inEEG.srate,round(inEEG.srate/2),max(size(inEEG.data)),max_freq,para);
else
    [cs,coh,nave]=data2cs_event(inEEG.data',inEEG.srate,round(inEEG.srate/2),max(size(inEEG.data)),max_freq);
end

for i = 1:mf
    disp('Mphke..');
        eval(['outEEG.FC.iCOH.'...
             strrep(inEEG.FC.parameters.bands{i,2},' ','_') ...
             '.adj_matrix=abs(imag(mean(coh(:,:,' int2str(round(min(str2num(inEEG.FC.parameters.bands{i,1})))) ':'...
             int2str(max(str2num(inEEG.FC.parameters.bands{i,1}))) '),3)));']);
end
