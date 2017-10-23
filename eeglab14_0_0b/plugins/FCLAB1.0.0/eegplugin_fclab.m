function vers = eegplugin_fclab(fig, try_strings, catch_strings)
vers = 'FCLAB v1.0';
if nargin < 3
    error('eegplugin_fclab requires 3 arguments');
end;

menu = findobj(fig, 'tag', 'tools');

comfc = [try_strings.no_check 'EEG = pop_fclab(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' catch_strings.new_and_hist];
graphfc = [try_strings.no_check 'EEG = pop_fcgraph(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' catch_strings.new_and_hist];
vizfc = [try_strings.no_check 'pop_fcvisual(EEG);' catch_strings.new_and_hist];
netstats = [try_strings.check_chanlocs 'pop_fcvisual_parameters(EEG);' catch_strings.new_and_hist];
submenu = uimenu( menu, 'Label', 'FCLAB', 'separator', 'on');

uimenu(submenu, 'label', 'Compute Functional Connectivity', 'callback', comfc, 'userdata', 'study:on');
uimenu(submenu, 'label', 'Visualize Functional Connectivity', 'callback', vizfc);
uimenu(submenu, 'label', 'Run graph analysis', 'callback', graphfc, 'userdata', 'study:on');
uimenu(submenu, 'label', 'Network Statistics', 'callback', netstats);
 
return;