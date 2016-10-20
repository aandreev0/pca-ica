%% sort segmented cells by correlation with mean of segmented cells signal

time_resolution = 15; % min
realTime_point = 1;

data_dir = 'E:\aa\npvf-reachr\fish3_ReaChR_Unknown_900msExp_2xBin_2minInt_100mmLens_15PercFPGA_1';
metadata = load([data_dir,'\metadata.mat']);
start_time = metadata.start_time;

load([data_dir,'\all_cell_sigs_t001-120.mat'])
load([data_dir,'\all_segcentroid_t001-120.mat'])

save_dir = 'corr_connections_corr_th_0.1';


show_std_img = 0;
show_max_img = 1;
scale_factor = 1;
save_fig = 1;

max_realTime_point = length(all_segcentroid);

date_format = 'mm/dd/yy HH:MM:SS';

corr_bins = linspace(0,   1, 10);
dist_bins = linspace(0, 400, 40);
corr_th = 0.1;

avg_corrs = zeros(20,max_realTime_point);
cell_corrcoeff_hist = zeros(length(corr_bins),max_realTime_point);
cell_distances_hist = zeros(20,max_realTime_point);

for realTime_point = 1:max_realTime_point
    time_point = start_time + minutes(time_resolution*(realTime_point-1));
    max_img = imread([data_dir,'/MAX_colored.tif'], realTime_point);
    cell_sigs = all_cell_sigs{realTime_point};
    cell_positions = all_segcentroid{realTime_point};

    cell_distances = pdist2(cell_positions,cell_positions);
    cell_corrcoeff = corrcoef(cell_sigs');
    
    [dist_N,dist_C,corr_N,corr_C,N3]=hist_corr_matrix(cell_sigs, cell_positions,corr_bins,dist_bins,corr_th);
    cell_corrcoeff_hist(:,realTime_point) = corr_N/sum(corr_N);
    
    if 1==1
        mean_cell_sig = mean(cell_sigs);
        size(mean_cell_sig); % 1 120

        cell_sigs_mean_corr = zeros(size(cell_sigs,1),1);

        for kk = 1:length(cell_sigs_mean_corr)
            cell_sigs_mean_corr(kk) = abs(min(min(corrcoef(mean_cell_sig,cell_sigs(kk,:)))));
        end

        find(cell_sigs_mean_corr==max(cell_sigs_mean_corr));

        [sorted_sigs_mean_corr, sorted_ids] = sort(cell_sigs_mean_corr);

        fig_10x_id = (realTime_point - rem(realTime_point,10))/10+1;
        subplot_10x_id = rem(realTime_point,10);
        if subplot_10x_id==0
            subplot_10x_id=10;
            fig_10x_id = fig_10x_id - 1;
        end
        [fig_10x_id, subplot_10x_id]

        f = figure(fig_10x_id);
        subplot(2,5,subplot_10x_id);
        if show_max_img == 1
            imshow(max_img)
            hold on
        end
        if show_std_img == 1
            imshow(std_img)
            caxis([10 100])
            hold on
        end

        list_cell_ids = randsample(size(cell_positions,1), min([100 size(cell_positions,1)]));
        for kk = 1:length(list_cell_ids)/2
            cell_ids = list_cell_ids((kk-1)*2 + [1 2]);
            w = abs(cell_corrcoeff(cell_ids(1),cell_ids(2)));
            avg_corrs(kk,realTime_point) = w;
            if w>corr_th
                w = w*10;
                plot(cell_positions(cell_ids,1)*scale_factor,cell_positions(cell_ids,2)*scale_factor,'-','LineWidth',w)%,'Color',[1 1 1])
                %xlim([0 400])
                %ylim([0 700])
                hold on
            end
        end
        title(datestr(time_point,date_format));
        set(gca,'Ydir','reverse')
        if exist([data_dir,'/',save_dir])==0
            mkdir([data_dir,'/',save_dir]);
        end

        fig_fname = [data_dir,'\',save_dir,'\',sprintf('%03d',fig_10x_id),'.png'];
        f.Position = [420 70 1200 1000];
        f.Color = [1 1 1];
        g = gca;
        g.Position(3) = 0.16;

        if subplot_10x_id==10 || max_realTime_point==realTime_point
            fig_img = getframe(gcf);
            imwrite(fig_img.cdata, fig_fname);
            close(fig_10x_id)
        end
    end
end

f = figure(1)
pcolor(1:max_realTime_point,corr_bins, cell_corrcoeff_hist);
shading flat
renderTimeAxis(start_time, max_realTime_point, 15, 240);
ylabel 'Correlation coefficient, R^2';

saveas(f,[data_dir,'\corr_hist.fig']);