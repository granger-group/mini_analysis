%% Mini analysis pipeline

%README here

%%
%Turn off warnings for loading wave objects
warning('off', 'MATLAB:unknownObjectNowStruct');
warning('off', 'MATLAB:MKDIR:DirectoryExists');

psc_flag = -1; %-1 for epsc, 1 for ipsc - IPSCs not supported yet, to be added later

%% Load in all traces from a given epoch

%Ask user to specify the epoch to analyze and load in the avg mat file to
%extract the component traces
epoch = input('Enter the epoch to analyze: ');
current_epoch = strcat('AD0_e',num2str(epoch),'p1avg.mat');

if isfile(current_epoch)
    load(current_epoch);
else
    error('No such epoch file in current directory')
end

%extract the component traces of that epoch
data_file_name = strcat('AD0_e',num2str(epoch),'p1avg'); %re-making the name of the avegae epoch file
trace_names = eval(strcat(data_file_name,'.UserData.Components')); %extract the trace_names

n_traces = length(trace_names);

%load in all traces from the current epoch
for i = 1:n_traces
    new_traces = strcat(trace_names{i},'.mat');
    load(new_traces)
end

%% Filter and clean-up traces to remove RC check

traces = [];
raw_traces = [];
for i = 1:n_traces %cycle thirough all the traces
    temp_trace = eval(trace_names{i}); 
    temp_raw = temp_trace.data; %keep an array of raw traces
    temp_raw(1:5000) = [];% remove the RC check
    raw_traces = [raw_traces; temp_raw];
     
    temp_trace = decimate(temp_trace.data,10); %downsample
    temp_trace(1:500) = []; %remove the RC check
    traces = [traces; temp_trace]; %Add to a single array
end
 %% Add in manual EPSC selection and template assignment

mean_psc = manual_mini_selection(raw_traces(1,:),psc_flag); %manually select some EPSCs to an average

template_match(mean_psc,psc_flag); %match the mean PSC to a template 


%% Tweak detection parameters and run initial detection

template = multiexponential_psc(0,Risetau,Decaytau);
template = decimate(template,10); %decimate the template for downstream steps

mini_detection(traces, psc_flag, template);

%pause;
%% run through and detect all events
noise_events = [];
template_events = [];
 
%loop through traces, get all events by both methods
 for i = 1:n_traces
    current_trace = traces(i,:);
    
    current_thresh_events = threshold_detection(current_trace,psc_flag,noise_threshold);
    current_template_events = template_detection(current_trace,template,template_threshold,psc_flag);
    
    noise_events = [noise_events; current_thresh_events];
    template_events = [template_events; current_template_events];

 end

 %combine events
 %events = (template_events == 1) & (noise_events ==1) %intersection
 events = (template_events == 1) | (noise_events ==1); %Union

 %% Convert expand events array and make sure it aligns to the raw data
raw_events = zeros(size(raw_traces)); %Pre-allocate the raw events array

for i = 1:size(events,1) %loop through each trace
    
    current_events = events(i,:); %get the events on the donwsampled trace
    event_times = find(current_events); %pull out the index of each event
    event_times = event_times*10; %multiply the index by 10 to align with raw trace
    raw_events(i,event_times) = 1; %assign each index 1 in the raw events array

    current_raw_events = find_nearest_peak(raw_traces(i,:),raw_events(i,:),psc_flag); %clean up to make sure the peaks are aligned to the true peak
    raw_events(i,:) = current_raw_events; %assign the cleaned up version

end


%% Manual mini quality check

mini_qc(raw_traces,raw_events); %QC, will assign to the base workspace a variable "final_events", a logical array with a "1" at the peak of a detected event

%pause;
%% Graph and save data

%Get amplitudes, IEIs, and mean traces

%Transpose the raw data and the events
raw_traces = raw_traces';
final_events = final_events';
event_times = find(final_events);

%Inter event intervals (in seconds):
IEIs = diff(event_times)/10000;

%amplitudes
amplitudes = [];
for i = 1:length(event_times); 
    peak = mean(raw_traces(event_times(i)-4:event_times(i)+5)); %take the mean 1 ms around the peak
    baseline = mean(raw_traces(event_times(i)-70:event_times(i)-20)); %take the mean for 5 ms, startign 2 ms before the peak
    current_amp = peak - baseline;
    amplitudes = [amplitudes; current_amp];
end

%Average the traces for all peaks
mean_trace = raw_traces(event_times(1)-300:event_times(1)+300);
for i = 2:length(event_times);
    current_subtrace = raw_traces(event_times(i)-300:event_times(i)+300); %start with 30 ms on either side of the peak
    mean_trace = mean_trace + current_subtrace; %add onto running total
end
mean_trace= mean_trace ./ length(event_times);


%Plot the data
figure('Position',[100 100 1200 600]); hold on
subplot(1,3,1);
plot(mean_trace); title('Mean trace');
subplot(1,3,2); cdfplot(amplitudes); title('Amplitude CDF'); xlabel('pA');
subplot(1,3,3); cdfplot(IEIs); title('IEI CDF'); xlabel('seconds');

%save the data
if psc_flag == -1
    saveas(gcf,'mEPSC_results.png'); %save the figure
    save('mEPSC_results.mat','raw_traces','final_events','amplitudes','IEIs','mean_trace','threshold');
elseif psc_flag == 1
    saveas(gcf,'mIPSC_results.png'); %save the figure
    save('mIPSC_results.mat','raw_traces','final_events','amplitudes','IEIs','mean_trace','threshold');
end
% 
% clear all

