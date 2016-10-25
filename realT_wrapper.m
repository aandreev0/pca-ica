% data analysis wrapper for multiple real time datapoints

corr_bins = linspace(0,   1, 20);
dist_bins = linspace(0, 200, 20);

time_resolution = 15; % min

%data_folder = 'E:\aa\160918_huc-gcamp-KeepingLightsOn';

metadata = load([data_folder,'\metadata.mat']);
start_time = metadata.start_time;
load([data_folder,'\subtractMean0_all_cell_sigs_t001-120.mat'])
load([data_folder,'\subtractMean0_all_segcentroid_t001-120.mat'])

max_realTime_point = 69;length(all_segcentroid);
avg_corrs = zeros(20,max_realTime_point);
cell_corrcoeff_hist = zeros(length(corr_bins),max_realTime_point);
cell_distances_hist = zeros(length(dist_bins),max_realTime_point);
cell_distances_corr_hist = zeros(length(dist_bins),max_realTime_point);
cell_N3_hist = zeros(max_realTime_point,length(corr_bins),length(dist_bins));

cell_segmented = zeros(1,max_realTime_point);

corr_th = 0.0;
trial_time_window = 5:60; % part of trial analyzed for correlation

avg_sigs = zeros(size(all_cell_sigs{1},2),max_realTime_point);

%% day/night data collectors
all_day_data = [];
all_night_data = [];
all_datum = [];

start_day = datenum(datestr(start_time,'yyyy/mm/dd'));
day1_9am  = start_day + hours(9);
day1_10pm = start_day + hours(22);
day2_9am  = start_day + hours(24+9);
day2_10pm = start_day + hours(24+22);
day3_9am  = start_day + hours(48+9);
day3_10pm = start_day + hours(48+22);

%% run cycle
for realTime_point = min_realTime:max_realTime_point
    time_point = start_time + minutes(time_resolution*(realTime_point-1));
    max_img = imread([data_folder,'/MAX_colored.tif'], realTime_point);
    cell_sigs_raw      = all_cell_sigs{realTime_point};
    cell_positions = all_segcentroid{realTime_point};
    cell_sigs = cell_sigs_raw(:,trial_time_window);
    [dist_N,dist_C,corr_N,corr_C,N3] = hist_corr_matrix(cell_sigs,cell_positions,corr_bins,dist_bins,corr_th);
    cell_distances_hist(:,realTime_point) = dist_N/sum(dist_N);
    cell_corrcoeff_hist(:,realTime_point) = corr_N/sum(dist_N);
    cell_segmented(realTime_point) = size(cell_sigs,1);
    cell_N3_hist(realTime_point,:,:) = N3/sum(sum(N3));
    cell_distances_corr_hist(:,realTime_point) = sum(N3.*repmat(corr_bins',1,length(dist_bins)))./sum(N3);
    avg_sigs(:,realTime_point) = mean(cell_sigs_raw);
    
    % collect stats into day/night collectors
    time_point_time = start_time + minutes(time_resolution * (realTime_point-1));
    datum = sum(corr_bins'.*cell_corrcoeff_hist(:,realTime_point));
    %datum = length(cell_positions);
    %datum = time_point_time; % use for testing of time segregation
    all_datum = [all_datum,datum];
    if (time_point_time<day1_10pm && time_point_time>=day1_9am) || ...
       (time_point_time<day2_10pm && time_point_time>=day2_9am) || ...
       (time_point_time<day3_10pm && time_point_time>=day3_9am)
       % day
       all_day_data = [all_day_data, datum];
    else
       % night
       all_night_data = [all_night_data, datum];
    end
end
%disp('ttest2 of day-vs-night data:' );
%[h,p] = ttest2(all_day_data,all_night_data)
% corr hist
f1 = figure(1);
clf
subplot(3,1,1)
[n,b] = hist(all_night_data);
plot(b,n/sum(n)*100,'ro-')
hold on
[n,b] = hist(all_day_data,b);
plot(b,n/sum(n)*100,'b-o')
legend('Night','Day')

ylabel 'Density';
xlabel 'R^2 coefficient';
ylabel 'Occurrence, %';
title(['R^2 histogram: ', 'trial window: ',num2str(trial_time_window(1)),'..',int2str(trial_time_window(end))]);

subplot(3,1,2)
hold off
plot(all_datum,'ro-')


%renderTimeAxis(start_time, max_realTime_point, 15, 240);
ylabel 'Average R^2';
title 'Average correlation through recording';
legend('Night','Day')


subplot(3,1,3)
plot(all_night_data,'-or')
hold on
plot(all_day_data,'-ob')
legend('Night','Day')
ylabel 'Average R^2';
title 'Average correlation: day versus night';
xlabel 'Trial';


f2 = figure(2);
clf

subplot(4,1,1);
%avg_sigs = avg_sigs -min(min(avg_sigs));
f0_avg_sigs = repmat(mean(avg_sigs(10:50,:)),size(avg_sigs,1),1);
dff0_avg_sigs = (avg_sigs - f0_avg_sigs)./f0_avg_sigs;
pcolor(dff0_avg_sigs)
%caxis([0 10])
shading flat
renderTimeAxis(start_time, max_realTime_point, 15, 240);
title 'Average of cellular signals (\DeltaF/F_0)';

subplot(4,1,2)
pcolor(1:max_realTime_point,corr_bins,cell_corrcoeff_hist)
shading flat
renderTimeAxis(start_time, max_realTime_point, 15, 240);
ylabel 'Correlation R^2';
ylim([corr_th 1]);
title(['R^2 coefficient distribution: ','trial window: ',num2str(trial_time_window(1)),'..',int2str(trial_time_window(end))]);

subplot(4,1,3)
pcolor(1:max_realTime_point,dist_bins,cell_distances_hist)
title 'Distribution of distances between cells';
shading flat
renderTimeAxis(start_time, max_realTime_point, 15, 240);
ylabel 'Distance, px';

subplot(4,1,4)
%plot(cell_segmented)
pcolor(1:max_realTime_point, dist_bins, cell_distances_corr_hist)
title 'Dependency of correlation on distance between cells';
ylabel 'Distance, px';
shading flat
renderTimeAxis(start_time, max_realTime_point, 15, 240);
ylabel 'Distance, px';
saveas(f1,[data_folder,'\corr_plot.fig']);
saveas(f2,[data_folder,'\histograms.fig']);

%% plot day-time difference

% start_time is datenum
%{
start_day = datenum(datestr(start_time,'yyyy/mm/dd'));
day1_9am  = start_day + hours(9);
day1_10pm = start_day + hours(22);
day2_9am  = start_day + hours(24+9);
day2_10pm = start_day + hours(24+22);
day3_9am  = start_day + hours(48+9);
day3_10pm = start_day + hours(48+22);

all_day_data = [];
all_night_data = [];

for realTime_point = 1:max_realTime_point
   time_point_time = start_time + minutes(time_resolution * (realTime_point-1));
   
   % run some math here
   
   if (time_point_time<day1_10pm && time_point_time>=day1_9am) || ...
      (time_point_time<day2_10pm && time_point_time>=day2_9am) || ...
      (time_point_time<day3_10pm && time_point_time>=day3_9am)

       % day
       all_day_data = [all_day_data, time_point_time];
   else
       % night    
       all_night_data = [all_night_data, time_point_time];
   end
end
%}
