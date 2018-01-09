function [Th] = treeHierarchy(L, M, BC_max)

%Tree hierarchy quantifies the tradeoff between large scale integration in
%the MST and the overload of central nodes.

Th = L/(2*M*BC_max);
