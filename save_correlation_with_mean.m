%% sort segmented cells by correlation with mean of segmented cells signal
time_resolution = 15; % min
realTime_point = 1;

data_dir = 'E:\aa\npvf-reachr\fish3_ReaChR_Unknown_900msExp_2xBin_2minInt_100mmLens_15PercFPGA_1';
metadata = load([data_dir,'\metadata.mat']);
start_time = metadata.start_time;

load([data_dir,'\all_cell_sigs_t001-120.mat'])
load([data_dir,'\all_segcentroid_t001-120.mat'])

max_realTime_point = size(all_segcentroid,2);
avg_corrs = zeros(20,max_realTime_point);
scale_factor = 1; % scale factor between original data analyzed and STD/MAX projection used for imshow
cmap = colormap(jet(200));
cmap = cmap(101:200,:);
%cmap = [((0:1:99)/100); zeros(100,1)'; zeros(100,1)']';

subplot_y_num = 2;
subplot_x_num = 5;
subplot_total_num = subplot_x_num*subplot_y_num;

for realTime_point = 1:max_realTime_point
    time_point = start_time + minutes(time_resolution*(realTime_point-1));
    max_img = imread([data_dir,'/MAX_colored.tif'], realTime_point);
    std_img = imread([data_dir,'/STD_img.tif'], realTime_point);

    cell_sigs = all_cell_sigs{realTime_point};
    
    avg_cell_sig = mean(cell_sigs);
    cell_positions = all_segcentroid{realTime_point};

    cell_distances = pdist2(cell_positions,cell_positions);
    cell_corrcoeff = corrcoef(cell_sigs');



    mean_cell_sig = mean(cell_sigs);
    size(mean_cell_sig); % 1 120

    cell_sigs_mean_corr = zeros(size(cell_sigs,1),1);

    for kk = 1:length(cell_sigs_mean_corr)
        cell_sigs_mean_corr(kk) = abs(min(min(corrcoef(mean_cell_sig,cell_sigs(kk,:)))));
    end

    find(cell_sigs_mean_corr==max(cell_sigs_mean_corr));

    [sorted_sigs_mean_corr, sorted_ids] = sort(cell_sigs_mean_corr);

    fig_10x_id = (realTime_point - rem(realTime_point,subplot_total_num))/subplot_total_num+1;
    subplot_10x_id = rem(realTime_point,subplot_total_num);
    if subplot_10x_id==0
        subplot_10x_id=subplot_total_num;
        fig_10x_id = fig_10x_id - 1;
    end
    [fig_10x_id, subplot_10x_id]
    
    f = figure(fig_10x_id);
    subplot(subplot_y_num,subplot_x_num,subplot_10x_id);
    imshow(std_img)
    caxis([0 100])
    hold on
    list_cell_ids = randsample(length(cell_positions),length(cell_positions));
   
    for kk = 1:length(list_cell_ids) %length(cell_positions)
        cell_id = list_cell_ids(kk);
        w = floor((corrcoef(avg_cell_sig,cell_sigs(cell_id,:)).^2)*100) + 1;
        w = w(1,2);
        plot(cell_positions(cell_id,1)*scale_factor,cell_positions(cell_id,2)*scale_factor,'o',...
            'MarkerFaceColor',cmap(w,:),'Color',cmap(w,:),'Markers',5)
        hold on
            
    end
    %xlim([0 400]/scale_factor)
    %ylim([0 700]/scale_factor)
    set(gca,'Ydir','reverse')

    title(datestr(time_point));
    if exist([data_dir,'\corr_plots_10x_noImg_corr_with_Avg_abs_R/'])==0
        mkdir([data_dir,'\corr_plots_10x_noImg_corr_with_Avg_abs_R/']);
    end
    fig_fname = [data_dir,'\corr_plots_10x_noImg_corr_with_Avg_abs_R\',sprintf('%03d',fig_10x_id),'.png'];
    f.Position = [420 70 1200 1000];
    f.Color = [1 1 1];
    g = gca;
    g.Position(3) = 0.16;
    
    if subplot_10x_id==subplot_total_num || max_realTime_point==realTime_point
        fig_img = getframe(gcf);
        imwrite(fig_img.cdata, fig_fname);
        close(fig_10x_id)
    end
    
    %close all
end
