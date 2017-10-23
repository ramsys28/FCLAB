function outEEG = fcmetric_correlation(inEEG)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%
%   >>  outEEG = fcmetric_correlation(inEEG);
%
% Inputs:
%           inEEG  - input EEG dataset
%   
%    
% Outputs:
%           outEEG  - output dataset
%
% Info:
%           Computes Pearson's temporal correlation coefficient for each 
%           possible pair of EEG channels and for every band as well.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mf = size(inEEG.FC.parameters.bands, 1);
[m, n, o] = size(inEEG.data);
outEEG = inEEG;
disp('>> FCLAB: Pearson''s correlation is being computed...');

for i = 1:mf
    testEEG = inEEG;
    freq_range = str2num(inEEG.FC.parameters.bands{i,1});
    [testEEG, com, b] = pop_eegfiltnew(testEEG, freq_range(1));
    [testEEG, com, b] = pop_eegfiltnew(testEEG, [], freq_range(2));
    if (o == 1)
        temp_adj = corrcoef(testEEG.data');
    else
        temp_adj = corrcoef(mean(testEEG.data,3)'); % events data
    end
    eval(['outEEG.FC.correlation.' strrep(inEEG.FC.parameters.bands{i,2},' ','_') '.adj_matrix=temp_adj;']);
end;
