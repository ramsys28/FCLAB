function vers = eegplugin_fclab(fig, try_strings, catch_strings)
vers = 'FCLAB v1.0';
if nargin < 3
    error('eegplugin_fclab requires 3 arguments');
end

menu = findobj(fig, 'tag', 'tools');

comfc = [try_strings.no_check 'EEG = pop_fclab(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' catch_strings.new_and_hist];
% vizfc = [try_strings.check_chanlocs 'EEG = pop_fcvisual(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' catch_strings.new_and_hist];
vizfc = [try_strings.no_check 'pop_fcvisual(EEG);' catch_strings.new_and_hist];
graphfc = [try_strings.no_check 'EEG = pop_fcgraph(EEG);' catch_strings.new_and_hist];
graphparamvizfc = [try_strings.no_check 'pop_fcvisual_parameters(EEG);' catch_strings.new_and_hist];
vizmst = [try_strings.no_check 'pop_fcvisual_MSTs(EEG);' catch_strings.new_and_hist];
submenu = uimenu(menu, 'Label', 'FCLAB', 'separator', 'on');

uimenu(submenu, 'label', 'Compute Functional Connectivity', 'callback', comfc);
% uimenu( submenu, 'label', 'Visualize Functional Connectivity', 'callback', vizfc, 'userdata','chanloc:off');
uimenu(submenu, 'label', 'Visualize Functional Connectivity', 'callback', vizfc);
uimenu(submenu, 'label', 'Graph/MST analysis', 'callback', graphfc);
uimenu(submenu, 'label', 'Visualize Graph/MST parameters', 'callback', graphparamvizfc);
uimenu(submenu, 'label', 'Visualize MST', 'callback', vizmst);
 
return