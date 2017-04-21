function outEEG=fcgraph(inEEG)
metric=inEEG.FC.graph_prop.metric;
disp('>> FCLAB: Computing graph theoretical parameters')
eval(['bands=fieldnames(inEEG.FC.' metric ');']);


if((inEEG.FC.graph_prop.threshold==1) & isempty(inEEG.FC.graph_prop.absthr) & isempty(inEEG.FC.graph_prop.propthr))
    error('No Value for Threshold')
    return;
else
    if(~isempty(inEEG.FC.graph_prop.absthr))
        for i=1:length(bands)
            eval(['inEEG.FC.' metric '.' bands{i} '.absthr_'...
                num2str(inEEG.FC.graph_prop.absthr)...
                '=threshold_absolute(inEEG.FC.' metric '.' bands{i} '.adj_matrix,' inEEG.FC.graph_prop.absthr ');']);
        end;
    end;

    if(~isempty(inEEG.FC.graph_prop.propthr))
        for i=1:length(bands)
            eval(['inEEG.FC.' metric '.' bands{i} '.propthr_'...
                num2str(inEEG.FC.graph_prop.absthr) '%'...
                '=threshold_propotional(inEEG.FC.' metric '.' bands{i} '.adj_matrix,' inEEG.FC.graph_prop.propthr/100 ');']);
        end;
    end;

end;


for i=1:length(bands)
    eval(['L = weight_conversion(inEEG.FC.' metric '.' bands{i} '.adj_matrix, ''lengths'' );']) %connection-length matrix
    D = distance_wei(L); %distance matrix
    %local measures
    eval(['inEEG.FC.' metric '.'  bands{i}  '.local.BC = betweenness_wei(L)./((inEEG.nbchan-1)*(inEEG.nbchan-2));']);
    eval(['inEEG.FC.' metric '.'  bands{i}  '.local.DEG = degrees_und(inEEG.FC.' metric '.' bands{i} '.adj_matrix)./(inEEG.nbchan-1);'])
    eval(['[~, ~, intEEG.FC.' metric '.'  bands{i}  '.local.ECC, ~, ~] = charpath(D);'])
    eval(['inEEG.FC.' metric '.'  bands{i}  '.local.clustcoef = clustering_coef_wu(inEEG.FC.' metric '.' bands{i} '.adj_matrix);'])
    eval(['inEEG.FC.' metric '.'  bands{i}  '.local.Elocal = efficiency_wei(inEEG.FC.' metric '.' bands{i} '.adj_matrix, 1);']) %or 2 for modified version
    eval(['inEEG.FC.' metric '.'  bands{i}  '.local.EC = eigenvector_centrality_und(inEEG.FC.' metric '.' bands{i} '.adj_matrix);'])

    %global measures
    eval(['[~, ~, ~, inEEG.FC.' metric '.'  bands{i}  '.global.rad, inEEG.FC.' metric '.'  bands{i}  '.global.diam] = charpath(D);']);
    eval(['inEEG.FC.' metric '.'  bands{i}  '.global.LN = leaf_nodes(inEEG.FC.' metric '.' bands{i} '.adj_matrix);']);
    eval(['[inEEG.FC.' metric '.'  bands{i}  '.global.lambda, ~, ~, ~, ~] = charpath(D);']);
    %outEEG.FC.Correlation.global.DEGcor = pearson(temp_adj); %CHECK
    %THIS --> this is fot weighted
    eval(['inEEG.FC.' metric '.'  bands{i}  '.global.Eglobal = efficiency_wei(inEEG.FC.' metric '.' bands{i} '.adj_matrix, 0);']);

end;
outEEG=inEEG;
