% pop_fclab() - Functional Connectivity Lab for EEGLAB  
%
% Usage:
%   >>  OUTEEG = pop_fclab( INEEG, type );
%
% Inputs:
%   INEEG   - input EEG dataset
%   type    - type of processing. 1 process the raw
%             data and 0 the ICA components.
%   
%    
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   SAMPLE, EEGLAB 

% Copyright (C) <year>  <name of author>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [outEEG, com] = fclab(inEEG, params)
if nargin < 1
    error('FCLAB:Need parameters');
	return;
end

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

%% Perform network analysis
outEEG = inEEG;
[m, n, o] = size(inEEG.data);
if strcmp(params.metric, 'cor');
    if isempty(params.bands) % whole signal
        if (o == 1)
            temp_adj = corrcoef(inEEG.data');
        else
            temp_adj = corrcoef(mean(inEEG.data,3)'); % events data
        end
        outEEG.FC.Correlation.adj_matrix.all_freq=temp_adj;
        if params.graph==1
            L = weight_conversion(temp_adj, 'lengths'); %connection-length matrix
            D = distance_wei(L); %distance matrix
            %local measures
            outEEG.FC.Correlation.all_freq.local.BC = betweenness_wei(L)./((n-1)*(n-2));
            outEEG.FC.Correlation.all_freq.local.DEG = degrees_und(temp_adj)./(n-1);
            [~, ~, outEEG.FC.Correlation.all_freq.local.ECC, ~, ~] = charpath(D);
            outEEG.FC.Correlation.all_freq.local.clustcoef = clustering_coef_wu(temp_adj);
            outEEG.FC.Correlation.all_freq.local.Elocal = efficiency_wei(temp_adj, 1); %or 2 for modified version
            outEEG.FC.Correlation.all_freq.local.EC = eigenvector_centrality_und(temp_adj);

            %global measures
            [~, ~, ~, ~, outEEG.FC.Correlation.all_freq.global.diam] = charpath(D);
            [~, ~, ~, outEEG.FC.Correlation.all_freq.global.rad, ~] = charpath(D);
            outEEG.FC.Correlation.all_freq.global.LN = leafNodes(temp_adj);
            [outEEG.FC.Correlation.all_freq.global.lambda, ~, ~, ~, ~] = charpath(D);
            %outEEG.FC.Correlation.global.DEGcor = pearson(temp_adj); %CHECK
            %THIS --> this is fot weighted
            outEEG.FC.Correlation.all_freq.global.Eglobal = efficiency_wei(temp_adj, 0);
        end;
    else % frequency bands
        [mf nf] = size(params.bands);
        for i = 1:mf
            testEEG=inEEG;
            freq_range=str2num(params.bands{i,1});
            [testEEG, com, b] = pop_eegfiltnew(testEEG, freq_range(1));
            [testEEG, com, b] = pop_eegfiltnew(testEEG, [],freq_range(2));
            
            if (o == 1)
                temp_adj = corrcoef(testEEG.data');
            else
                temp_adj = corrcoef(mean(testEEG.data,3)'); % events data
            end
            eval(['outEEG.FC.Correlation.' strrep(params.bands{i,2},' ','_') '.adj_matrix=temp_adj;']);
            
            if params.graph==1
                L = weight_conversion(temp_adj, 'lengths'); %connection-length matrix
                D = distance_wei(L); %distance matrix
                %local measures
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.local.BC = betweenness_wei(L)./((n-1)*(n-2));']);
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.local.DEG = degrees_und(temp_adj)./(n-1);'])
                eval(['[~, ~, outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.local.ECC, ~, ~] = charpath(D);'])
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.local.clustcoef = clustering_coef_wu(temp_adj);'])
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.local.Elocal = efficiency_wei(temp_adj, 1);']) %or 2 for modified version
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.local.EC = eigenvector_centrality_und(temp_adj);'])

                %global measures
                eval(['[~, ~, ~, ~, outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.global.diam] = charpath(D);']);
                eval(['[~, ~, ~, outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.global.rad, ~] = charpath(D);']);
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.global.LN = leaf_nodes(temp_adj);']);
                eval(['[outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.global.lambda, ~, ~, ~, ~] = charpath(D);']);
                %outEEG.FC.Correlation.global.DEGcor = pearson(temp_adj); %CHECK
                %THIS --> this is fot weighted
                eval(['outEEG.FC.Correlation.'  strrep(params.bands{i,2},' ','_')  '.global.Eglobal = efficiency_wei(temp_adj, 0);']);
            end;
            

            clear temp adj testEEG;
        end; 
    end;
end
outEEG.FC.parameters=params;

disp('>> FCLAB: Done!');

%% Print executed command
com = sprintf('fclab( %s, %s );', inputname(1), 'params');

return;
