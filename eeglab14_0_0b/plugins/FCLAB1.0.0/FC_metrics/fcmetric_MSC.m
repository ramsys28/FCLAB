function outEEG = fcmetric_MSC(inEEG) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%
%   >>  outEEG = fcmetric_MSC(inEEG);
%
% Input(s):
%           inEEG   - input EEG dataset
%    
% Output(s):
%           outEEG  - output EEG dataset
%
% Info:
%           Computes the magnitude squared coherence for each possible pair 
%           of EEG channels and for every band as well.
%
% Mathematical background:
%           For two signals, assume x, y, the magnitude squared coherence 
%           at frequency f, |R(f)|^2, can be defined as follows:
%
%                   |R(f)|^2 = (|C(f)|^2)/[(C_xx(f)*C_yy(f))]
%
%           where C(f) is the cross-spectrum of signals x, y at f, and C_xx, 
%           C_yy are the power spectra of x and y, respectively, at the same 
%           frequency.
%
% Fundamental basis:
%           The coherence values vary on the interval [0, 1], where 1 
%           indicates a perfect linear prediction of y from x.
%
% Reference(s):
%           Rosenberg J.R., Amjad A.M., Breeze P., Brilinger  D.R., and D.
%           M. Halliday (1989). The Fourier approach to the identification 
%           offunctional coupling between neuronal spike trains. Prog.
%           Biophys. molec. Biol., 53, 1-31.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m1 n1] = size(inEEG.data);
mf = size(inEEG.FC.parameters.bands,1);
outEEG = inEEG;
disp('>> FCLAB: MSC is being computed...');

for i1 = 1:m1
    for j1=i1:m1
        [Cxy F]=mscohere(inEEG.data(i1,:),inEEG.data(j1,:),50,1,[],inEEG.srate);
        for bands=1:mf
            freq_range=str2num(inEEG.FC.parameters.bands{bands,1});
            for i=1:length(F)
                if F(i,1)>freq_range(1)
                    start_freq=i;
                    break;
                end
            end
            for i=1:length(F)
                if F(i,1)>freq_range(2)
                    stop_freq=i-1;
                    break;
                end
            end
        end
         eval(['outEEG.FC.MSC.'...
             strrep(inEEG.FC.parameters.bands{bands,2},' ','_') ...
             '.adj_matrix(i1,j1)=mean(Cxy(start_freq:stop_freq-1,1));']);     
    end
end

for i = 1:mf
eval(['outEEG.FC.MSC.'...
             strrep(inEEG.FC.parameters.bands{i,2},' ','_') ...
             '.adj_matrix(outEEG.nbchan,:)=0;']);
eval(['outEEG.FC.MSC.'...
             strrep(inEEG.FC.parameters.bands{i,2},' ','_') ...
             '.adj_matrix=outEEG.FC.MSC.'...
             strrep(inEEG.FC.parameters.bands{i,2},' ','_') ...
             '.adj_matrix+outEEG.FC.MSC.'...
             strrep(inEEG.FC.parameters.bands{i,2},' ','_') ...
             '.adj_matrix''']);
end
