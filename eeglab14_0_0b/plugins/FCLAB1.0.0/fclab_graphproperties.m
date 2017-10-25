function struct = fclab_graphproperties(W, band_ID)

if issymmetric(W)
    directed = 0;
else
    directed = 1;
end

if isequal(unique(W), [0;1])
    weighted = 0;
else
    weighted = 1;
end

struct = [];

tic;
if(weighted && ~directed) %weighted & undirected
    struct = wu(W);
elseif(~weighted && ~directed) %binary & undirected
    struct = bu(W);
end
timer = toc;

disp(['>> fclab_graphproperties: Elapsed time for ', band_ID, ' band = ', num2str(timer), ' sec']);

return


function s = wu(C)
s.global.assortativity=assortativity_wei(C,0);
% s.length_matrix = weight_conversion(C, 'lengths');

A = C;
B = C > 0;
A(B) = 1./C(B);
s.length_matrix = A;

s.distance = distance_wei(s.length_matrix); %distance matrix
s.nodal.BC = betweenness_wei(s.length_matrix);
s.nodal.BCnorm = betweenness_wei(s.length_matrix)./((size(C,1)-1)*(size(C,1)-2));
[s.global.CPL,s.global.GE,s.nodal.ECC,s.global.radius,s.global.diameter] = charpath(s.distance);
s.nodal.CC = clustering_coef_wu(C);
s.global.DEN = density_und(C);
%[s.global.GEdiff,s.edge.Ediff] = diffusion_efficiency(C); problem check
s.edge.EBC = edge_betweenness_wei(C);
s.local.LE = real(efficiency_wei(C,1));
s.local.EVC = eigenvector_centrality_und(C);
[s.edge.Erange,s.global.eta,s.edge.Eshort,s.global.fs] = erange(C); %%%%%%%%%%%%Attention
[s.wlaks.Wq,s.wlaks.twalk,s.wlaks.wlq] = findwalks(C); %%%%%%%%%%%%Attention
[s.edge.JointDeg,s.global.J_od,s.global.J_id,s.global.J_bl] = jdegree(C);
[s.local.loc_assort_pos,s.local.loc_assort_neg] = local_assortativity_wu_sign(C);
s.local.STR = strengths_und(C);
return

function s = bu(C)
s.global.assortativity = assortativity_bin(C, 0);
s.length_matrix = C;
s.distance = distance_bin(s.length_matrix); %distance matrix
s.nodal.BC = betweenness_bin(s.length_matrix);
s.nodal.BCnorm = betweenness_bin(s.length_matrix)./((size(C,1)-1)*(size(C,1)-2));
[s.global.CPL,s.global.GE,s.nodal.ECC,s.global.radius,s.global.diameter] = charpath(s.distance);
s.nodal.CC = clustering_coef_bu(C);
s.global.DEN = density_und(C);
s.edge.EBC = edge_betweenness_bin(C);
s.local.LE = real(efficiency_bin(C,1));
s.local.EVC = eigenvector_centrality_und(C);
[s.edge.Erange,s.global.eta,s.edge.Eshort,s.global.fs] = erange(C);
[s.wlaks.Wq,s.wlaks.twalk,s.wlaks.wlq] = findwalks(C);
[s.edge.JointDeg,s.global.J_od,s.global.J_id,s.global.J_bl] = jdegree(C);
% [s.local.loc_assort_pos,s.local.loc_assort_neg] = local_assortativity_wu_sign(C);
s.local.STR = strengths_und(C);
return;
