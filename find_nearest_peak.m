function output_events = find_nearest_peak(trace,input_events,psc_flag);
%Event detection for PSCs tends to miss the peak by a few ms, so this
%function cleans that up - given an current trace and an input_events array
%indicating the location of putative peaks, this funciton outputs a new
%events array with the events aligned on the peak
%Inputs:
%   trace - voltage clampe trace
%   input_events - logical array, same length as trace, with 1's for each
%   putative peak
%   psc_flag - -1 for EPSC, 1 for IPSC

    event_inds = find(input_events);
    output_events = zeros(size(input_events));

    for i = 1:length(event_inds)
        current_ind = event_inds(i);
        %get 5 ms on either side of the event from the raw trace
        temp_trace = trace(current_ind-5:current_ind+5);
        switch psc_flag
            case -1
                [~, peak_ind] = min(temp_trace);
            case 1
                [~, peak_ind] = max(temp_trace);
        end

        new_ind = current_ind-6+peak_ind;
        output_events(new_ind) = 1;

end