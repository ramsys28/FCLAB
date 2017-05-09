function outEEG = fcmetric_PLI(inEEG)

mf = size(inEEG.FC.parameters.bands, 1);
[m, ~, o] = size(inEEG.data);
outEEG = inEEG;
temp_adj = zeros(m, m);

for i = 1:mf
    testEEG = inEEG;
    freq_range = str2num(inEEG.FC.parameters.bands{i,1});
    [testEEG, ~, ~] = pop_eegfiltnew(testEEG, freq_range(1));
    [testEEG, ~, ~] = pop_eegfiltnew(testEEG, [], freq_range(2));
    
    if (o > 1)
        X = mean(testEEG.data, 3); %events data
    else
        X = testEEG.data;
    end
        
    for j = 1:m-1
        for k = i+1:m
            hilbert1 = hilbert(X(j, :));
            hilbert2 = hilbert(X(k, :));
            df = angle(hilbert1) - angle(hilbert2);
            temp_adj(j, k) = abs(mean((sign(sin(df)))));
        end
    end
    temp_adj = temp_adj + triu(temp_adj)';
    
    eval(['outEEG.FC.PLI.' strrep(inEEG.FC.parameters.bands{i,2},' ','_') '.adj_matrix = temp_adj;']);
end;
