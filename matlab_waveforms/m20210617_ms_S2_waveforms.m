clear 
close all
clc

%% Import data and add dependencies

folder = 'C:\Users\Yes\Documents\Josh\Mountainsort analysis\data\20210722 Joe Manual Sort vs Mountainsort\20190802 Joe TMaze E0741 Single Day 2';
addpath('C:\Users\Yes\Documents\Josh\Mountainsort analysis\matlab_waveforms\waveform_functions');
addpath('C:\Users\Yes\Documents\Josh\Josh MATLAB\tuckermcclure-matlab-plot-big-6e92329');
cd(folder)

spikes_S2 = open('spikes_spike2.mat');
spikes_ms = open('spikes_ms.mat');

%% compare spikes one tetrode at a time
% Need uppercase and lowercase to account for var name difference
ms = spikes_ms.tt1;
S2 = spikes_S2.TT1;

% Need to rearrange spike2 spikes into ms format (spiketimes,waveforms1...)
S2 = rearrange_spike2_waveforms(S2);
% plotspikes(ms,7,500);
% plotspikes(S2,6,500);

% Get mean waveform for each unit
ms_mean = getmeantrace(ms,1);
S2_mean = getmeantrace(S2,1);

% Align spike2 and mountainsort recordings
% Shorten time of ms then interp spike2 

ms_aligned = alignwfs(ms_mean,1,122);
S2_interp = interpS2(S2_mean,32,120);

%% 
%% MS Amps waveforms and times

unit_ID = 6

plotwf(ms_mean,unit_ID,sprintf('ms-%d',unit_ID))



ms_times = spikes_ms.tt2;
fs=30303;
amps = amp_time_plot(ms_times,unit_ID,fs);

%% Spike2 Amps waveforms and times
unit_ID = 6
plotwf(S2_interp,unit_ID,sprintf('S2-%d',unit_ID))

S2_times = S2;
fs=30303;

amps = amp_time_plot(S2_times,unit_ID,1);



%%
% close all
% for i = 1:size(S2_interp,1)
%     plotwf(S2_interp,i,sprintf('S2-%d',i))
% end
%     
% for i = 1:size(ms_aligned,1)
%     plotwf(ms_aligned,i,sprintf('ms-%d',i))
% end

%%

ms_field = [];
S2_field = [];


%%
% 
% x = 1:length(ms_field);
% gs = fspecial('gaussian',3,1);
% ms_field_smoothed = filter2(gs,ms_field);
% S2_field_smoothed = filter2(gs,S2_field);
% 
% 
% ms_interp = spline(1:40,ms_field_smoothed,0:.1:40);
% x_interp = 1:length(ms_interp);
% S2_interp = spline(1:40,S2_field_smoothed,0:.1:40);
% 
% 
% figure
% subplot(2,1,1)
% plot(x_interp,ms_interp)
% title('ms')
% subplot(2,1,2)
% plot(x_interp,S2_interp)
% title('S2')
% 
