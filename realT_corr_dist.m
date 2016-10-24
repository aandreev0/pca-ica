% realT_scaffold
% collecting data into time bins or just as a function of time
% use any matlab data as source, metadata for start_time
% collect info on distance-correlation relation between cells

time_resolution = 15; % min

%data_folder = 'E:\aa\160918_huc-gcamp-KeepingLightsOn\';

metadata = load([data_folder,'\metadata.mat']);
start_time = metadata.start_time;
load([data_folder,'\subtractMean0_all_cell_sigs_t001-120.mat'])
load([data_folder,'\subtractMean0_all_segcentroid_t001-120.mat'])

max_realTime_point = length(all_segcentroid);

%% corr-dist parameteres
cell_corrcoeff_bins = linspace(0,1,10);
cell_dist_bins = [50 150]; % centers
corr_th = 0.0;

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
for realTime_point = 1:max_realTime_point
    time_point_time = start_time + minutes(time_resolution * (realTime_point-1));
    cell_pos = all_segcentroid{realTime_point};
    cell_sigs = all_cell_sigs{realTime_point};
    
    [dist_N,dist_C,corr_N,corr_C,N3]=hist_corr_matrix(cell_sigs, cell_pos,cell_corrcoeff_bins,cell_dist_bins,corr_th);

    
    
    % collect stats into day/night collectors
    datum = [sum(N3(:,1)/sum(N3(:,1)).*corr_C'), sum(N3(:,2)/sum(N3(:,2)).*corr_C')];
    %datum = time_point_time; % use for testing of time segregation
    all_datum = [all_datum; datum];
    if (time_point_time<day1_10pm && time_point_time>=day1_9am) || ...
       (time_point_time<day2_10pm && time_point_time>=day2_9am) || ...
       (time_point_time<day3_10pm && time_point_time>=day3_9am)
       % day
       all_day_data = [all_day_data; datum];
    else
       % night
       all_night_data = [all_night_data; datum];
    end
end

figure(1)
clf

subplot(3,1,1)
plot(all_datum(:,1),'k--')
hold on
plot(all_datum(:,2),'k-')
legend ('0-100\mum','100-200\mum');
renderTimeAxis(start_time, max_realTime_point, 15, 240);
ylabel 'Average correlation, R^2';



subplot(3,1,2)
plot(all_day_data(:,1),'b--')
hold on
plot(all_day_data(:,2),'b-')
plot(all_night_data(:,1),'r--')
plot(all_night_data(:,2),'r-')
legend ('Day 0-100\mum','Day 100-200\mum','Night 0-100\mum','Night 100-200\mum');
ylabel 'Average correlation, R^2';

subplot(3,1,3)
[n,b] = hist(all_day_data(:,1));
plot(b,n,'b--')
hold on
[n,b] = hist(all_day_data(:,2),b);
plot(b,n,'b-')
[n,b] = hist(all_night_data(:,1),b);
plot(b,n,'r--')
[n,b] = hist(all_night_data(:,2),b);
plot(b,n,'r-')

legend ('Day 0-100\mum','Day 100-200\mum','Night 0-100\mum','Night 100-200\mum');

xlabel 'Average correlation, R^2';

