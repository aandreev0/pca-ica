% realT_scaffold
% collecting data into time bins or just as a function of time
% use any matlab data as source, metadata for start_time

time_resolution = 15; % min

%data_folder = 'E:\aa\160918_huc-gcamp-KeepingLightsOn\';

metadata = load([data_folder,'\metadata.mat']);
start_time = metadata.start_time;
data_container_file = '\CovEvals_10-120.mat';
load([data_folder, data_container_file]);
max_realTime_point = length(data_container);

%% day/night data collectors
all_day_data = [];
all_night_data = [];
all_datum = [];

all_day_data2 = [];
all_night_data2 = [];
all_datum2 = [];

start_day = datenum(datestr(start_time,'yyyy/mm/dd'));
day1_9am  = start_day + hours(9);
day1_10pm = start_day + hours(22);
day2_9am  = start_day + hours(24+9);
day2_10pm = start_day + hours(24+22);
day3_9am  = start_day + hours(48+9);
day3_10pm = start_day + hours(48+22);




%% run cycle
for realTime_i = 1:max_realTime_point
    

    %% map
    
    CovEvals_perc = data_container{realTime_i}.CovEvals*100/data_container{realTime_i}.covtrace;
      
    
    % collect stats into day/night collectors
    time_point_time = start_time + minutes(time_resolution * (realTime_i-1));
    datum = find(cumsum(CovEvals_perc)>=95);
    datum = datum(1);
    datum2 = sum(CovEvals_perc(1:3));
    
    %datum = time_point_time; % use for testing of time segregation
    all_datum = [all_datum,datum];
    all_datum2 = [all_datum2,datum2];
    if (time_point_time<day1_10pm && time_point_time>=day1_9am) || ...
       (time_point_time<day2_10pm && time_point_time>=day2_9am) || ...
       (time_point_time<day3_10pm && time_point_time>=day3_9am)
       % day
       all_day_data = [all_day_data, datum];
       all_day_data2 = [all_day_data2, datum2];

    else
       % night
       all_night_data = [all_night_data, datum];
       all_night_data2 = [all_night_data2, datum2];
    end
end

figure
clf
subplot(3,1,1)
plot(all_datum)
hold on

renderTimeAxis(start_time, 195, 15, 240);
ylabel '# of PCs covering >95% variance';

subplot(3,1,2)
plot(all_night_data,'ro-')
hold on
plot(all_day_data,'bo-')
legend('Night', 'Day')

subplot(3,1,3)
[n,b]=hist(all_day_data);
plot(b,n/sum(n)*100,'b-')
hold on
[n,b]=hist(all_night_data,b);
plot(b,n/sum(n)*100,'r-')

figure
clf
subplot(3,1,1)
plot(all_datum2)
hold on

renderTimeAxis(start_time, 195, 15, 240);
ylabel 'Variance covered by first 3 PCs, %';

subplot(3,1,2)
plot(all_night_data2,'ro-')
hold on
plot(all_day_data2,'bo-')
legend('Night', 'Day')
subplot(3,1,3)
[n,b]=hist(all_day_data2);
plot(b,n/sum(n)*100,'b-')
hold on
[n,b]=hist(all_night_data2,b);
plot(b,n/sum(n)*100,'r-')
