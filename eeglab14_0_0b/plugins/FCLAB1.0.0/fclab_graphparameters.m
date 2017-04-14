function outEEG=fclab_graphparameters(inEEG,metric)

L = weight_conversion(temp_adj, 'lengths'); %connection-length matrix
D = distance_wei(L); %distance matrix
%local measures
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.local.BC = betweenness_wei(L)./((n-1)*(n-2));']);
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.local.DEG = degrees_und(temp_adj)./(n-1);'])
eval(['[~, ~, outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.local.ECC, ~, ~] = charpath(D);'])
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.local.clustcoef = clustering_coef_wu(temp_adj);'])
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.local.Elocal = efficiency_wei(temp_adj, 1);']) %or 2 for modified version
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.local.EC = eigenvector_centrality_und(temp_adj);'])

%global measures
eval(['[~, ~, ~, ~, outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.global.diam] = charpath(D);']);
eval(['[~, ~, ~, outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.global.rad, ~] = charpath(D);']);
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.global.LN = leaf_nodes(temp_adj);']);
eval(['[outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.global.lambda, ~, ~, ~, ~] = charpath(D);']);
%outEEG.FC.Correlation.global.DEGcor = pearson(temp_adj); %CHECK
%THIS --> this is fot weighted
eval(['outEEG.FC.' metric '.'  strrep(EEG.FC.parameters.bands{i,2},' ','_')  '.global.Eglobal = efficiency_wei(temp_adj, 0);']);
