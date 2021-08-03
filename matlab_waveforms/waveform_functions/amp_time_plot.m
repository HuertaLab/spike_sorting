function amps = amp_time_plot(wf_times,ID,fs)
% Creates plot showing the amplitude of spikes over time
% need to import waveforms and the times of each spike in first variable
% and the ID of the unit to be examined second
% import fs- sampling rate

%% Get spike amplitudes

a = size(wf_times{ID,2},1);
amps = zeros(4,a);
for i = 1:a
    for j=2:5
        amps(j-1,i) = (max(wf_times{ID,j}(i,:))-min(wf_times{ID,j}(i,:))).*1000;
    end
end

%% 
% largest channel
[~,ch] = max(mean(amps,2));
s=60;

xr = [0,300/s];
yr = [0,0.5];
figure
plot((wf_times{ID,1}./fs)/s,amps(ch,:),'o')
xlim(xr)
ylim(yr)
set(gca,'XTick',[0,5])
set(gca,'YTick',[0,0.25,.5])
xlabel('Time(min)')
ylabel('Amplitude(mV)')

% xlim(xr)
% subplot(4,1,2)
% plot(wf_times{ID,1}./fs,amps(2,:),'o')
% subplot(4,1,3)
% plot(wf_times{ID,1}./fs,amps(3,:),'o')
% subplot(4,1,4)
% plot(wf_times{ID,1}./fs,amps(4,:),'o')