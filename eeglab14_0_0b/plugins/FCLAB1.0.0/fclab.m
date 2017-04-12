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
            eval(['outEEG.FC.Correlation.' params.bands{i,2} '.adj_matrix=temp_adj']);
            
            if params.graph==1
                L = weight_conversion(temp_adj, 'lengths'); %connection-length matrix
                D = distance_wei(L); %distance matrix
                %local measures
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.local.BC = betweenness_wei(L)./((n-1)*(n-2));']);
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.local.DEG = degrees_und(temp_adj)./(n-1);'])
                eval(['[~, ~, outEEG.FC.Correlation.'  params.bands{i,2} '.local.ECC, ~, ~] = charpath(D);'])
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.local.clustcoef = clustering_coef_wu(temp_adj);'])
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.local.Elocal = efficiency_wei(temp_adj, 1);']) %or 2 for modified version
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.local.EC = eigenvector_centrality_und(temp_adj);'])

                %global measures
                eval(['[~, ~, ~, ~, outEEG.FC.Correlation.'  params.bands{i,2} '.global.diam] = charpath(D);']);
                eval(['[~, ~, ~, outEEG.FC.Correlation.'  params.bands{i,2} '.global.rad, ~] = charpath(D);']);
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.global.LN = leafNodes(temp_adj);']);
                eval(['[outEEG.FC.Correlation.'  params.bands{i,2} '.global.lambda, ~, ~, ~, ~] = charpath(D);']);
                %outEEG.FC.Correlation.global.DEGcor = pearson(temp_adj); %CHECK
                %THIS --> this is fot weighted
                eval(['outEEG.FC.Correlation.'  params.bands{i,2} '.global.Eglobal = efficiency_wei(temp_adj, 0);']);
            end;
            
            
            
            
            clear temp adj testEEG;
        end; 
    end;
end

com = sprintf('fclab( %s, %s );', inputname(1), 'params');

return;
