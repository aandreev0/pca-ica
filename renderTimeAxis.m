function renderTimeAxis(start_date, t_max, time_res, time_axis_sampling)
    % start_date = [datenum(YYYY,MM,DD,H24,MIN,SEC), axisShift]
    if length(start_date)==1 % 
        start_date = [start_date,0];
    end

    time_axis = (1+start_date(2)):t_max;
    start_date = addtodate(start_date(1), time_res*start_date(2),'minute');

    datetime_axis = time_axis;
    
    

    for ii=1:t_max
       datetime_axis(ii) =  addtodate(start_date, time_res*(ii-1),'minute');
    end
    time_sampling = 1:(time_axis_sampling/time_res):t_max;

    ax = gca;
    set(ax,'XTick', time_axis(time_sampling));
    set(ax,'XTickLabel', datestr(datetime_axis(time_sampling),'HH:MM'));
    xlabel 'Recording time';
    ylabel 'Trial time, s';
end
