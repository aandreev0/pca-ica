function [dist_N,dist_C,corr_N,corr_C,N3]=hist_corr_matrix(cell_sigs, cell_pos,cell_corrcoeff_bins,cell_dist_bins,corr_th)

    cell_distances = pdist2(cell_pos,cell_pos);
    cell_corrcoeff = corrcoef(cell_sigs');

    corr_m = cell_corrcoeff.^2;
    dist_m = cell_distances;
    mask = tril(true(size(corr_m)),-1);
    c = corr_m(mask);
    [corr_N,corr_C]=hist(c(find(c>corr_th)),cell_corrcoeff_bins);
   
    d = dist_m(mask);
    [dist_N,dist_C]=hist(d,cell_dist_bins);
    dat = [c, d];
    dat = dat(find(dat(:,1)>corr_th),:);
    N3 = hist3(dat,{cell_corrcoeff_bins,cell_dist_bins});
end