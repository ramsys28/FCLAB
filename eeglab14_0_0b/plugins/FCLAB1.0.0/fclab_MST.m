function [MST_net, MST_params]=fclab_MST(Matrix, band_ID)
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

Matrix = double(Matrix);
n = size(Matrix, 2);

disp('fclab_MST: Automatically ignoring negative weights (if not already discarded)...');
Matrix(Matrix<0) = 0; %retain only positive values (for sure)

tic;
[MST_net.Kruskal, MST_net.cost] =  minSpanTreeKruskal(1./Matrix);
[MST_net.links, MST_net.weights] = minimal_spanning_tree(1./Matrix);

%Compute Degree of every node
MST_params.local.DEG_MST = (degrees_und(MST_net.Kruskal))';
MST_params.local.DEG_MST = MST_params.local.DEG_MST./(n-1); %normalize per Subject

%Compute Betweenness centrality of every node
MST_params.local.BC_MST = betweenness_wei(MST_net.Kruskal);
MST_params.local.BC_MST = MST_params.local.BC_MST./((n-1)*(n-2));

%Compute Eccentricity of every node, given edges and corresponding weights
E = [MST_net.links MST_net.weights];
[MST_params.local.ECC_MST(:,1), MST_params.global.rad_MST, MST_params.global.diam_MST, ~, ~] = grEccentricity(E);
MST_params.local.ECC_MST = MST_params.local.ECC_MST./MST_params.global.diam_MST;

%Compute some MST global metrics
MST_params.global.leaves_MST = max(size(leaf_nodes(MST_net.Kruskal)));
MST_params.global.leaf_fraction_MST = max(size(leaf_nodes(MST_net.Kruskal)))/(n-1);
MST_params.global.Th_MST = treeHierarchy(MST_params.global.leaves_MST, n-1, max(MST_params.local.BC_MST));
MST_params.global.DEGcor_MST = pearson(MST_net.Kruskal);
MST_params.global.kappa_MST = kappa(MST_params.local.DEG_MST);
timer = toc;
disp(['fclab_MST: Elapsed time for ', band_ID, ' band = ', num2str(timer), ' sec']);
disp(' ');

return;
