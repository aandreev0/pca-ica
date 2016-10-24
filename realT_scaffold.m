% realT_scaffold
% collecting data into time bins or just as a function of time
% use any matlab data as source, metadata for start_time

time_resolution = 15; % min

data_folder = '';

metadata = load([data_folder,'\metadata.mat']);
start_time = metadata.start_time;
load([data_folder,'\subtractMean0_all_cell_sigs_t001-120.mat'])
load([data_folder,'\subtractMean0_all_segcentroid_t001-120.mat'])

max_realTime_point = length(all_segcentroid);

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
    
    % [dist_N,dist_C,corr_N,corr_C,N3]=hist_corr_matrix(cell_sigs, cell_pos,cell_corrcoeff_bins,cell_dist_bins,corr_th)

    
    
    % collect stats into day/night collectors
    datum = sum(corr_bins'.*cell_corrcoeff_hist(:,realTime_point));
    
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



