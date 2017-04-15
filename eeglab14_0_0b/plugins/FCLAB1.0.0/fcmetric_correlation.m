function outEEG=fcmetric_correlation(inEEG)
mf = size(inEEG.FC.parameters.bands,1);
[m, n, o] = size(inEEG.data);
outEEG=inEEG;
for i = 1:mf
    testEEG = inEEG;
    freq_range=str2num(inEEG.FC.parameters.bands{i,1});
    [testEEG, com, b] = pop_eegfiltnew(testEEG, freq_range(1));
    [testEEG, com, b] = pop_eegfiltnew(testEEG, [],freq_range(2));
    if (o == 1)
        temp_adj = corrcoef(testEEG.data');
    else
        temp_adj = corrcoef(mean(testEEG.data,3)'); % events data
    end
    eval(['outEEG.FC.correlation.' strrep(inEEG.FC.parameters.bands{i,2},' ','_') '.adj_matrix=temp_adj;']);
end;

    