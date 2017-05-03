function [MST_net, MST_params]=fclab_MST(Matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [MST_net, MST_params] = fclab_MST(Matrix)
%
% Input(s):
%           Matrix, Weighted matrix [nxn]
%
% Outputs:
%           MST_net, MST network using Kruskal's/Prim's algorithm
%           MST_params, MST's local and global parameters
%
% Notes:
%           The weighted matrix should be non-negative.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('MST_params');

Matrix = double(Matrix);
n = size(Matrix, 2);
Matrix(Matrix<0) = 0; %retain only positive values (for sure)
    
[MST_net.Kruskal, MST_net.cost] =  minSpanTreeKruskal(1./Matrix);
[MST_net.links, MST_net.weights] = minimal_spanning_tree(1./Matrix);

%Compute Degree of every node
MST_params.DEG = (degrees_und(MST_net.Kruskal))';
MST_params.DEG = MST_params.DEG./(n-1); %normalize per Subject

%Compute Betweenness centrality of every node
MST_params.BC = betweenness_wei(MST_net.Kruskal);
MST_params.BC = MST_params.BC./((n-1)*(n-2));

%Compute Eccentricity of every node, given edges and corresponding weights
E = [MST_net.links MST_net.weights];
[MST_params.ECC(:,1), MST_params.rad, MST_params.diam, ~, ~] = grEccentricity(E);
MST_params.ECC = MST_params.ECC./MST_params.diam;

%Compute some MST global metrics
MST_params.leaves = max(size(leaf_nodes(MST_net.Kruskal)));
MST_params.leaf_fraction = max(size(leaf_nodes(MST_net.Kruskal)))/(n-1);
MST_params.Th = treeHierarchy(MST_params.leaves, n-1, max(MST_params.BC));
MST_params.DEGcor = pearson(MST_net.Kruskal);
MST_params.kappa = kappa(MST_params.DEG);

return;
