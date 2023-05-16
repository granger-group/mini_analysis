function output = multiexponential_psc(start_time,rise_tau,decay_tau)
    %inputs: peak_time, rise_tau, and decay_tau are all represented in
    %milliseconds
    %Based on eq. 3 from Pernia-Andrade et al, 2012 in Biophys Jour - a
    %simple sum of two exponents, one for rise, one for decay

    start_time = start_time/1000; %convert to seconds
    rise_tau = rise_tau/1000;
    decay_tau = decay_tau/1000;
        
    %Set the sample rate 
    dt = 0.0001; % 10 kHz

    %determine total length of the trace
    endtime = (decay_tau*5)+start_time; %make trace 5 times the decay constant (should be <1% of amplitude left)
    time = 0:dt:endtime; % 200 ms total length to start

    
    output = zeros(size(time));
    t = time >= start_time;
    decay_exp = zeros(size(time));
    rise_exp = zeros(size(time));

    decay_exp(t) = exp(-(time(t)-start_time) ./ decay_tau);
    rise_exp(t) = -exp(-(time(t)-start_time) ./ rise_tau);
    output = decay_exp +rise_exp;
    output = output ./ max(output);
    
%     figure; hold on;
%     plot(time,output); 
%     plot(time,decay_exp);
%     plot(time,rise_exp);
%     legend({'output','decay','rise'})
%      title('Multiexponential PSC template');
%     xlabel('Time (sec)')
    
end