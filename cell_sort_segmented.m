%% sort segmented cells by correlation with mean of segmented cells signal
start_time = datenum(2016,09,18,20,13,0);
time_resolution = 15; % min
realTime_point = 1;

dir = 'E:\aa\160918_huc-gcamp-KeepingLightsOn';
max_realTime_point = 177;
avg_corrs = zeros(20,max_realTime_point);
for realTime_point = 1:max_realTime_point
    time_point = start_time + minutes(time_resolution*(realTime_point-1));
    max_img = imread([dir,'/MAX_colored.tif'], realTime_point);
    cell_sigs = all_cell_sigs{realTime_point};
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
    %clf
    %hist(cell_sigs_mean_corr)

    [sorted_sigs_mean_corr, sorted_ids] = sort(cell_sigs_mean_corr);

    %%
    cell_ids = [80, 88];
    %{
    figure(3)
    plot(cell_sigs(cell_ids,:)')
    %}
    cell_distances(cell_ids(1),cell_ids(2));

    cell_corrcoeff(cell_ids(1),cell_ids(2));

    fig_10x_id = (realTime_point - rem(realTime_point,10))/10+1;
    subplot_10x_id = rem(realTime_point,10);
    if subplot_10x_id==0
        subplot_10x_id=10;
        fig_10x_id = fig_10x_id - 1;
    end
    [fig_10x_id, subplot_10x_id]
    
    f = figure(fig_10x_id);
    subplot(2,5,subplot_10x_id);
    %imshow(max_img)
    
   
    for kk = 1:20 %length(cell_positions)
        cell_ids = randsample(length(cell_positions),2);
        w = abs(cell_corrcoeff(cell_ids(1),cell_ids(2)))*10;
        avg_corrs(kk,realTime_point) = w;
        %if w>6
            plot(cell_positions(cell_ids,1)*2,cell_positions(cell_ids,2)*2,'-','LineWidth',w)%,'Color',[1 1 1])
            xlim([0 400])
            ylim([0 700])
            hold on
            %cell_a = cell_ids(1);
            %cell_b = cell_ids(2);
            %cell_b_corrcoeff = cell_corrcoeff(cell_b,:);
            %cell_b_corrcoeff(find(cell_distances(cell_b,:) < 2)) = -10; % cancel everything that is closer than 1 px to cell B
            %cell_b_corrcoeff(cell_a) = -10;
            %cell_c = find(cell_b_corrcoeff==max(cell_b_corrcoeff));
        %end
    end
     title(datestr(time_point));
    fig_fname = [dir,'/corr_plots_10x_noImg/',sprintf('%03d',fig_10x_id),'.png'];
    f.Position = [420 70 1200 1000];
    f.Color = [1 1 1];
    g = gca;
    g.Position(3) = 0.16;
    %{
    if subplot_10x_id==10 || max_realTime_point==realTime_point
        fig_img = getframe(gcf);
        imwrite(fig_img.cdata, fig_fname);
        close(fig_10x_id)
    end
    %}
    %close all
end
%{
figure(1)
clf
imshow(max_img)
hold on
cell_ids = [cell_a,cell_b];
w = abs(cell_corrcoeff(cell_ids(1),cell_ids(2)))*10;
plot(cell_positions(cell_ids,1)*2,cell_positions(cell_ids,2)*2,'-','LineWidth',w)%,'Color',[1 1 1])
[cell_distances(cell_a, cell_b),w/10]

cell_ids = [cell_a,cell_c];
w = abs(cell_corrcoeff(cell_ids(1),cell_ids(2)))*10;
plot(cell_positions(cell_ids,1)*2,cell_positions(cell_ids,2)*2,'-','LineWidth',w)%,'Color',[1 1 1])
[cell_distances(cell_a, cell_c),w/10]

cell_ids = [cell_c,cell_b];
w = abs(cell_corrcoeff(cell_ids(1),cell_ids(2)))*10;
plot(cell_positions(cell_ids,1)*2,cell_positions(cell_ids,2)*2,'-','LineWidth',w)%,'Color',[1 1 1])
[cell_distances(cell_b, cell_c),w/10]
legend('Cell A-Cell B','Cell A-Cell C','Cell C-Cell B')

text(cell_positions(cell_a,1)*2,cell_positions(cell_a,2)*2,'A')
text(cell_positions(cell_b,1)*2,cell_positions(cell_b,2)*2,'B')
text(cell_positions(cell_c,1)*2,cell_positions(cell_c,2)*2,'C')
%}
%{
figure(1)
surf(cell_corrcoeff);shading flat
view(2)
%}
%% 
