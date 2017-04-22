function struct=fclab_graphproperties(W)
if ~issymmetric(W)
    directed=0;
else
    directed=1;
end

if isequal(unique(W),[0;1])
    weighted=0;
else
    weighted=1;
end;
struct=[];
if(weighted & ~directed)
    struct=wu(W);
end;

return;


function s=wu(C)
%% QUESTION: WHAT WE DO WITH COMPLEX NUMBERS?
s.global.assortativity=assortativity_wei(C,0);
s.length_matrix = weight_conversion(C, 'lengths');
s.distance = distance_wei(s.length_matrix); %distance matrix
s.nodal.BC=betweenness_wei(s.length_matrix);
s.nodal.BCnorm=betweenness_wei(s.length_matrix)./((size(C,1)-1)*(size(C,1)-2));
[s.global.CPL,s.global.GE,s.nodal.ECC,s.global.radius,s.global.diameter] = ...
    charpath(s.distance);
s.nodal.CC=clustering_coef_wu(C);
s.gobal.DEN=density_und(C);
[s.gobal.GEdiff,s.edge.Ediff] = diffusion_efficiency(C);
s.edge.EBC = edge_betweenness_wei(C);
s.local.LE=real(efficiency_wei(C,1));
s.local.EVC=eigenvector_centrality_und(C);
[s.edge.Erange,s.global.eta,s.edge.Eshort,s.global.fs]=erange(C);
[s.wlaks.Wq,s.wlaks.twalk,s.wlaks.wlq] = findwalks(C);
[s.edge.JointDeg,s.global.J_od,s.global.J_id,s.global.J_bl] = jdegree(C);
[s.local.loc_assort_pos,s.local.loc_assort_neg] = local_assortativity_wu_sign(C);
s.local.STR=strengths_und(C);

return;
