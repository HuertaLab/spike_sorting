clear all
close all
clc
%%
addpath('C:\Users\Yes\Documents\Josh\Josh MATLAB\ms_matlab')
%%

msfolder = 'C:\Users\Yes\Documents\Josh\Mountainsort analysis\data\20210722 Joe Manual Sort vs Mountainsort'
cd(msfolder)

%% Importing data
% Import dependencies

rec = '20190802 Joe TMaze E0741 Single Day 2'

tt = 'tt1'

addpath(genpath('C:\Users\Yes\Documents\Josh\Josh MATLAB\ms_matlab\mountainsort convert to mda'))
addpath(genpath('C:\Users\Yes\Documents\Josh\Josh MATLAB\ms_matlab\tuckermcclure-matlab-plot-big-6e92329'))

% Import firings and raw data
firingsfolders = sprintf('%s\\%s\\output',msfolder,rec)
cd(firingsfolders)
firings = readmda(sprintf('%s\\%s\\output\\%s\\raw\\firings.mda',msfolder,rec,tt));
MouseSessionraw = sprintf('%s\\%s\\%s\\%s.mda',msfolder,rec,tt,tt);
addpath(MouseSessionraw);
addpath(pwd);
pos_data = sprintf('%s\\%s\\',msfolder,rec);
addpath(pos_data)
fs = 30303;

% Time window to get waveforms
hw1 = 0.001;
hw2 = 0.003;

% Downsample
downsample = 1;
dec = 3;

% firings = readmda('firings.mda'); %import firings.mda
raw = readmda('raw.mda'); % import raw data
ms = ms_objects(raw,firings);
ms.fspiketimes     % get spike times from firings.mda

% ms.bandpassfilter(l,h)
ms.hpf(600);
ms.lpf(3000);

% Get spikes from recording
ms.fspiketimes     % get spike times from firings.mda
ms.removeendspikes   % prevents indexing error

ms.pullspikes(hw1,hw2)   %get spikes from raw (time on either side of spike in s, - then +)

% build output struct

spikes_ms.tt1 = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]

%% Importing data
% Import dependencies

tt = 'tt2'

cd(firingsfolders)
firings = readmda(sprintf('%s/raw/firings.mda',tt));
MouseSessionraw = sprintf('%s\\%s\\%s\\%s.mda',msfolder,rec,tt,tt);
addpath(MouseSessionraw);

%%
% firings = readmda('firings.mda'); %import firings.mda
raw = readmda('raw.mda'); % import raw data
ms = ms_objects(raw,firings);
ms.fspiketimes     % get spike times fr

% Get spikes from recordingom firings.mda

if downsample == 1
    ms.downsample(dec);
end

% ms.bandpassfilter(l,h)
ms.hpf(600);
ms.lpf(3000);

% Get spikes from recording
ms.fspiketimes     % get spike times from firings.mda
ms.removeendspikes   % remove spikes from ends to prevent indexing error

ms.pullspikes(hw1,hw2)   %get spikes from raw (time on either side of spike in s)

% build output struct
spikes_ms.tt2 = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]

%%%%%%%%%%%%%%%%%%%%%%%%


%% Importing data
% Import dependencies

tt = 'tt3'

cd(firingsfolders)
firings = readmda(sprintf('%s/raw/firings.mda',tt));
MouseSessionraw = sprintf('%s\\%s\\%s\\%s.mda',msfolder,rec,tt,tt);
addpath(MouseSessionraw);

% firings = readmda('firings.mda'); %import firings.mda
raw = readmda('raw.mda'); % import raw data
ms = ms_objects(raw,firings);
ms.fspiketimes     % get spike times from firings.mda

% ms.bandpassfilter(l,h)
ms.hpf(600);
ms.lpf(3000);

% Get spikes from recording
ms.fspiketimes     % get spike times from firings.mda
ms.removeendspikes   % remove spikes from ends to prevent indexing error

ms.pullspikes(hw1,hw2)   %get spikes from raw (time on either side of spike in s)

% build output struct
spikes_ms.tt3 = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]

%% Importing data
% Import dependencies

tt = 'tt4'

cd(firingsfolders)
firings = readmda(sprintf('%s/raw/firings.mda',tt));
MouseSessionraw = sprintf('%s\\%s\\%s\\%s.mda',msfolder,rec,tt,tt);
addpath(MouseSessionraw);

% firings = readmda('firings.mda'); %import firings.mda
raw = readmda('raw.mda'); % import raw data
ms = ms_objects(raw,firings);
ms.fspiketimes     % get spike times from firings.mda

% ms.bandpassfilter(l,h)
ms.hpf(600);
ms.lpf(3000);

% Get spikes from recording
ms.fspiketimes     % get spike times from firings.mda
ms.removeendspikes   % remove spikes from ends to prevent indexing error

ms.pullspikes(hw1,hw2)   %get spikes from raw (time on either side of spike in s)

% build output struct
spikes_ms.tt4 = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]

%%

save('spikes_ms.mat','-struct','spikes_ms')
