function events = threshold_detection(trace,psc_flag,threshold)
%intended to identify PSCs (or other signals on same time scale) based on
%crossing a defined threshold
%Inputs: trace - current trace
%        psc_flag = -1 for EPSC (or minima), 1 for IPSC (or maxima)
%        threshold = amplitude threshold for identifying peaks
%both trace and template should be 1 Khz = decimated of down-sampled from
%10 Khz raw recording
%Output: events,a logical array the same size as input trace inidicating
%         location of peaks
    
    
    events = zeros(size(trace)); %create an empty vector for slotting in detected events
    
    [value,time]=findpeaks(trace*psc_flag); %find local peaks
            
            if psc_flag == -1 %Filter for EPSCs, or local minima
                for j=1:length(time) %cycle through the local peaks, filter out events not fitting the following criteria:
                    if time(j)>30 & time(j)<(length(trace)-6)... %filter out the first 30 ms and last 6 ms
                       & (value(j) + max(trace((time(j)-18):time(j)))) > threshold... %filter out any peaks below the noise
                       & trace(time(j)) < trace((time(j)-6):(time(j)-1))... %confirming it is indeed a local peak?
                       & trace(time(j)) < trace((time(j)+1):(time(j)+6)) % still confirming it is a local peak?
                                            
                        events(time(j))=1; %say it is a confirmed event
                    else
                    end
                end
                
            elseif psc_flag == 1 %Filter for IPSCs, or local maxima
                 for j=1:length(time); %cycle through the local peaks, filter out events not fitting the following criteria:
                    if time(j)>300 & time(j)<(length(trace)-6)... %filter out the first 30 ms and last 6 ms
                       & (value(j) - mean(trace((time(j)-18):time(j)-1))) > threshold... %filter out any peaks below the noise
                       & trace(time(j)) > trace((time(j)-6):(time(j)-1))... %confirming it is indeed a local peak?
                       & trace(time(j)) > trace((time(j)+1):(time(j)+6)) % still confirming it is a local peak?
                                            
                        events(time(j))=1; %say it is a confirmed event
                    else
                    end
                end
            end
            
            for j=1:(length(events)-1); %loop to confirm that two subsequent points aren't counted as the same event?
                if events(j+1)==1;
                    events(j)=0;
                else events(j)=events(j);
                end
            end
            
            %make sure events actually align with peaks
            events = find_nearest_peak(trace,events,psc_flag);
end