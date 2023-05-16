function mean_psc = manual_mini_selection(trace,psc_flag);
%function to allow user to manually select several PSCs and generate a
%rough average for the purposes of template matching
%Inputs:
    % trace - current trace
    % psc_flag = -1 for EPSC, 1 for EPSCs

%Output: mean PSC


    %Plot trace and pull out points
    h = figure; hold on; plot(trace);
    [xi,yi]= getpts;
    xi = round(xi);

    %clean up the x-index of each trace
    for i = 1:length(xi)
        switch psc_flag
            case -1
                [~, x_coord(i)] = min(trace(xi(i)-500:xi(i)+500));
            case 1
                [~, x_coord(i)] = max(trace(xi(i)-500:xi(i)+500));
        end
        
         x_coord(i) = x_coord(i)+round(xi(i))-501;
     end
    
    hold on;
    plot(x_coord,trace(x_coord),'xr');

    %create an empty array for slotting each example PSC    
    PSCs = zeros(length(xi),(100+500+1));
    
     %Extract and scale each example PSC
    figure; hold on;
     for i = 1:length(xi)
        
        temp_trace = trace(x_coord(i)-100:x_coord(i)+500); %get 10 ms and 50 ms after for each trace
        
        temp_trace = smooth(temp_trace,5); % smooth each trace out to eliminate noisey peak confound
        
        temp_trace = temp_trace-mean(temp_trace(1:99)); %subtract the baseline
        
        

        switch psc_flag
            case -1
                temp_scale = min(temp_trace(90:110)); 
            case 1
                temp_scale = max(temp_trace(90:110));
        end
        
        
        temp_trace = temp_trace/temp_scale*psc_flag; %scale the a fixed amplitude

        plot(temp_trace,'-k'); %plot each trace

        PSCs(i,:) = temp_trace;
    end

    %Take mean of all example PSCs
    mean_psc = mean(PSCs,1);

    switch psc_flag
            case -1
                mean_scale = min(mean_psc(90:110)); 
            case 1
                mean_scale = max(mean_psc(90:110));
    end
    
    mean_psc = mean_psc/mean_scale*psc_flag;

    plot(mean_psc,'-b');
end