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

%% Automatically download and add BCT, MITSE toolboxes in the plugin path
general_folders = dir('plugins/FCLAB1.0.0');
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
        BCT_version = dir('plugins/FCLAB1.0.0/BCT');
        
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
        addpath(strcat('plugins/FCLAB1.0.0/BCT/', BCT_version.name));
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
        delete('plugins/FCLAB1.0.0/code/issymmetric.m'); %due to conflict with MATLAB's issymetric
        addpath('plugins/FCLAB1.0.0/code');
        flag_MITSE = 1;
        break;
    end
end

%BCT doesn't exist - download from site and automatically unzip
if(flag_BCT == 0)
    disp('>> FCLAB: BCT toolbox not found!');
    url = 'https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0';
    filename = 'plugins/FCLAB1.0.0/BCT.zip';
    disp(['>> FCLAB: Downloading BCT toolbox from: ', url]);
    websave(filename, url);
    disp('>> FCLAB: Unzipping...');
    unzip('plugins/FCLAB1.0.0/BCT.zip', 'plugins/FCLAB1.0.0');
    folders = dir('plugins/FCLAB1.0.0/BCT');
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
    addpath(strcat('plugins/FCLAB1.0.0/BCT/', folders.name));
    delete('plugins/FCLAB1.0.0/BCT.zip');
    disp('>> FCLAB: Done...');
end

%MITSE doesn't exist - download from site and automatically unzip
if(flag_MITSE == 0)
    url = 'http://strategic.mit.edu/docs/matlab_networks/matlab_networks_routines.zip';
    filename = 'plugins/FCLAB1.0.0/matlab_networks_routines.zip';
    disp(' '); disp(['>> FCLAB: Downloading MIT Strategic Engineering toolbox from: ', url]);
    websave(filename, url);
    disp('>> FCLAB: Unzipping...');
    unzip('plugins/FCLAB1.0.0/matlab_networks_routines.zip', 'plugins/FCLAB1.0.0');
    delete('plugins/FCLAB1.0.0/code/issymmetric.m'); %due to conflict with MATLAB's issymetric
    disp('>> FCLAB: Adding to path...');
    addpath('plugins/FCLAB1.0.0/code');
    delete('plugins/FCLAB1.0.0/matlab_networks_routines.zip');
    disp('>> FCLAB: Done...');
end

%% Perform network analysis
outEEG = inEEG;
[m, n, o] = size(inEEG.data);
if strcmp(params.metric, 'cor');
    if (o == 1)
        temp_adj = corrcoef(inEEG.data');
    else
        temp_adj = corrcoef(mean(inEEG.data,3)');
    end  
end

disp(' ');
disp('>> FCLAB: Automatically discarding potential negative values...');
temp_adj(temp_adj < 0) = 0;
outEEG.FC.correlation.adj_matrix = temp_adj;

L = weight_conversion(temp_adj, 'lengths'); %connection-length matrix
D = distance_wei(L); %distance matrix

disp('>> FCLAB: Computing local metrics -> BC, DEG, ECC, clustering coefficient, local efficiency, eigenvalue centrality...');
outEEG.FC.correlation.local.BC = betweenness_wei(L)./((n-1)*(n-2));
outEEG.FC.correlation.local.DEG = degrees_und(temp_adj)./(n-1);
[~, ~, outEEG.FC.correlation.local.ECC, ~, ~] = charpath(D);
outEEG.FC.correlation.local.clustcoef = clustering_coef_wu(temp_adj);
outEEG.FC.correlation.local.Elocal = efficiency_wei(temp_adj, 1); %or 2 for modified version
outEEG.FC.correlation.local.EC = eigenvector_centrality_und(temp_adj);

disp('>> FCLAB: Computing global metrics -> diameter, radius, number of leaves, lambda, degree correlation, global efficiency...');
[~, ~, ~, ~, outEEG.FC.correlation.global.diam] = charpath(D);
[~, ~, ~, outEEG.FC.correlation.global.rad, ~] = charpath(D);
outEEG.FC.correlation.global.LN = leaf_nodes(temp_adj);
[outEEG.FC.correlation.global.lambda, ~, ~, ~, ~] = charpath(D);
outEEG.FC.correlation.global.DEGcor = pearson(temp_adj); %CHECK THIS
outEEG.FC.correlation.global.Eglobal = efficiency_wei(temp_adj, 0);

disp('>> FCLAB: Done!');

%% Print executed command
com = sprintf('fclab( %s, %s );', inputname(1), 'params');

return;
