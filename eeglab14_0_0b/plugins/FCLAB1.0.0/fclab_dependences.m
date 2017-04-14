% Automatically download and add BCT, MITSE toolboxes in the plugin path
eeglab_path=which('eeglab');
eeglab_path=strrep(eeglab_path,'eeglab.m','');
general_folders = dir([eeglab_path 'plugins/FCLAB1.0.0']);
flag_BCT = 0;
flag_MITSE = 0;

%remove non-folders and ./..
for k = length(general_folders):-1:1
    if~general_folders(k).isdir
        general_folders(k) = [];
        continue
    end
    
    fname = general_folders(k).name;
    if (fname(1) == '.')
        general_folders(k) = [ ];
    end
end

%search if BCT toolbox already exists
for k = length(general_folders):-1:1
    fname = general_folders(k).name;
    if (strcmp(fname, 'BCT') == 1)
        disp('>> FCLAB: BCT toolbox found!');
        BCT_version = dir([eeglab_path 'plugins/FCLAB1.0.0/BCT']);
        
        %find BCT version folder
        for j = length(BCT_version):-1:1
            if~BCT_version(j).isdir
                BCT_version(j) = [];
                continue
            end
    
            fname = BCT_version(j).name;
            if (fname(1) == '.')
                BCT_version(j) = [ ];
            end
        end
        
        disp('>> FCLAB: Adding to path...');
        addpath(strcat([eeglab_path 'plugins/FCLAB1.0.0/BCT/'], BCT_version.name));
        flag_BCT = 1;
        break;
    end
end

%search if MITSE toolbox already exists
for k = length(general_folders):-1:1
    fname = general_folders(k).name;
    if (strcmp(fname, 'code') == 1)
        disp('>> FCLAB: MIT SE toolbox found!');
        disp('>> FCLAB: Adding to path...');
        delete([eeglab_path 'plugins/FCLAB1.0.0/code/issymmetric.m']); %due to conflict with MATLAB's issymetric
        addpath([eeglab_path 'plugins/FCLAB1.0.0/code']);
        flag_MITSE = 1;
        break;
    end
end

%BCT doesn't exist - download from site and automatically unzip
if(flag_BCT == 0)
    disp('>> FCLAB: BCT toolbox not found!');
    url = 'https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0';
    filename = [eeglab_path 'plugins/FCLAB1.0.0/BCT.zip'];
    disp(['>> FCLAB: Downloading BCT toolbox from: ', url]);
    websave(filename, url);
    disp('>> FCLAB: Unzipping...');
    unzip([eeglab_path 'plugins/FCLAB1.0.0/BCT.zip'], [eeglab_path 'plugins/FCLAB1.0.0/']);
    folders = dir([eeglab_path 'plugins/FCLAB1.0.0/BCT']);
    for j = length(folders):-1:1
        if (~folders(j).isdir)
            folders(j) = [];
            continue
        end
    
        fname = folders(j).name;
        if (fname(1) == '.')
            folders(j) = [ ];
        end
    end
    disp('>> FCLAB: Adding to path...');
    addpath(strcat([eeglab_path 'plugins/FCLAB1.0.0/BCT/'], folders.name));
    delete([eeglab_path 'plugins/FCLAB1.0.0/BCT.zip']);
    disp('>> FCLAB: Done...');
end

%MITSE doesn't exist - download from site and automatically unzip
if(flag_MITSE == 0)
    url = 'http://strategic.mit.edu/docs/matlab_networks/matlab_networks_routines.zip';
    filename = [eeglab_path 'plugins/FCLAB1.0.0/matlab_networks_routines.zip'];
    disp(' '); disp(['>> FCLAB: Downloading MIT Strategic Engineering toolbox from: ', url]);
    websave(filename, url);
    disp('>> FCLAB: Unzipping...');
    unzip([eeglab_path 'plugins/FCLAB1.0.0/matlab_networks_routines.zip'], [eeglab_path 'plugins/FCLAB1.0.0/']);
    delete([eeglab_path 'plugins/FCLAB1.0.0/code/issymmetric.m']); %due to conflict with MATLAB's issymetric
    disp('>> FCLAB: Adding to path...');
    addpath([eeglab_path 'plugins/FCLAB1.0.0/code']);
    delete([eeglab_path 'plugins/FCLAB1.0.0/matlab_networks_routines.zip']);
    disp('>> FCLAB: Done...');
end