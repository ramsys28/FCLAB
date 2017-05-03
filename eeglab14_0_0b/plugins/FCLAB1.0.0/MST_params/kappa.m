function [k] = kappa(deg)

k = mean(deg)/mean(deg.^2);
