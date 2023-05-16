function events = template_detection(trace,template,threshold,psc_flag)
    %Function to identify PSCs based on how well they correlate with a
    %pre-determined template
    %Inputes: trace - raw voltage trace, template - modeled template of the IPSC (taken from multiexponential_psc.m);
    %psc_flag = -1 for EPSC, 1 for IPSC


    [~,peak_time] = max(template); %get the time of the peak of the template to aid in indexing later

    template = template*psc_flag; % adjust the template for EPSC or IPSC
    template_length = length(template);
    trace_length = length(trace);

    %Calculate corr of the template across trace
    for i = template_length:trace_length
        % Extract segment of voltage clamp trace
        trace_segment = trace(i-template_length+1:i);
    
        corr_result(i) = corr2(trace_segment,template);
    
    end

    %% do threshold detecion here to identify peaks in the correlation reaching the threshold
    corr_events = threshold_detection(corr_result,1,threshold);

    %corr_events identifies the peak of the correlation, corresponding to
    %the END of the template;
    %to normalize for where the peak of the template is:

    %calculate the shift size
    shift = length(template)-peak_time;
    
    %shift the corr_events to match where the peak should be on the input
    %trace
    events = circshift(corr_events,-shift);

    
    %loop through events to remove detection overlap
    event_ind = find(events);
    for i = 1:length(event_ind)
        j = event_ind(i);
        if any(events(j+1:j+5));
            events(j) = 0;
        else 
            events(j) = events(j);
        end
    end
    
    %make sure events actually align with peaks
    events = find_nearest_peak(trace,events,psc_flag);
end