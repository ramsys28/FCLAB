function vers = eegplugin_fclab(fig, try_strings, catch_strings)
vers = 'FCLAB v1.0';
if nargin < 3
    error('eegplugin_fclab requires 3 arguments');
end;



uimenu( fig, 'label', 'Compute Functional Connectivity', 'callback', [ 'EEG = pop_fclab(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' ]);
    
return;