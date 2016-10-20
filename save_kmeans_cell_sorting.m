%% split segmented cells with k-means algorithm

time_resolution = 15; % min
realTime_point = 1;


data_dir = 'E:\aa\npvf-reachr\fish24_ReaChR_Pos_900msExp_2xBin_2minInt_100mmLens_12PercFPGA_1';
metadata = load([data_dir,'\metadata.mat']);
start_time = metadata.start_time;

load([data_dir,'\all_cell_sigs_t001-120.mat'])
load([data_dir,'\all_segcentroid_t001-120.mat'])


save_dir = 'kmeans_sorting_k5_100randCells';

kmeans_k =5;
cmap = jet(kmeans_k);
show_std_img = 1;
show_max_img = 0;
scale_factor = 1;
save_fig = 1;

max_realTime_point = length(all_segcentroid);
mean_silh_value = zeros(10, max_realTime_point);

for realTime_point = 1:max_realTime_point
    time_point = start_time + minutes(time_resolution*(realTime_point-1));
    max_img = imread([data_dir,'/MAX_colored.tif'], realTime_point);
    std_img = imread([data_dir,'/STD_img.tif'], realTime_point);

    cell_sigs = all_cell_sigs{realTime_point};
    cell_positions = all_segcentroid{realTime_point};
    
    
    
    if 1==1
        
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
        
        for k_val = 2:10
            idxk = kmeans(cell_sigs, k_val);
            [silh]=silhouette( cell_sigs, idxk);
            mean_silh_value(k_val, realTime_point) = mean(silh);
        end
        
        % pick random 50 cells
        idxk = kmeans(cell_sigs, kmeans_k);
        idxk_n = hist(idxk,kmeans_k);
        [sn,si]=sort(idxk_n);
        
        rand_pick = randsample(size(cell_sigs,1), min([100, size(cell_sigs,1)]));
        for k=1:length(rand_pick)
            cell_id = rand_pick(k);
            w = find(si==idxk(cell_id));
            plot(cell_positions(cell_id,1)*scale_factor,cell_positions(cell_id,2)*scale_factor,'o',...
               'MarkerFaceColor',cmap(w,:), 'Color',cmap(w,:),'Markers',5)
            
            hold on
        end
        
        if save_fig == 1
            title(datestr(time_point));
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
end