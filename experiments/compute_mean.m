cd /home/thibaud/inverse_compositional_algorithm/experiments/edge_handling
load('rmse_ica_edge.txt');
load('rmse_ica.txt');
load('rmse_sift.txt');

rmse_ica_mean = mean(rmse_ica(1:2:end))
rmse_ica_edge_mean = mean(rmse_ica_edge(1:2:end))
rmse_sift_mean = mean(rmse_sift(1:2:end))
max_ica_mean = mean(rmse_ica(2:2:end))
max_ica_edge_mean = mean(rmse_ica_edge(2:2:end))
max_sift_mean = mean(rmse_sift(2:2:end))