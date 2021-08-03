clear all
close all
clc

%%

msfolder = 'C:\Users\Yes\Desktop\Mountainsort analysis\Mountainsort - LT data'
cd(msfolder)

folders = dir;

    
for ifolder = 1:length(folders)
    rec = folders(ifolder);
    if length(rec.name)<3
        continue
    else
        rec = rec.name
    end
    
    clear MLoutput
    

    
    
    %% Importing data
    % Import dependencies
    
    tt = 'tt1'
    
    addpath(genpath('C:\Users\Yes\Desktop\Mountainsort analysis\ms_matlab\mountainsort convert to mda'))
    addpath(genpath('C:\Users\Yes\Desktop\Mountainsort analysis\ms_matlab\tuckermcclure-matlab-plot-big-6e92329'))
    
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
    
    
    hw1 = 0.0015;
    hw2 = 0.0035;
    
    downsample = 0;
    dec = 3;
    
    % firings = readmda('firings.mda'); %import firings.mda
    raw = readmda('raw.mda'); % import raw data
    ms = ms_objects(raw,firings);
    ms.fspiketimes     % get spike times from firings.mda
    
    
    % ms.bandpassfilter(l,h)
    ms.hpf(600);
    ms.lpf(3000);
    
    
    
    %% Get spikes from recording
    
    
    ms.fspiketimes     % get spike times from firings.mda
    
    
    
    %% build output struct
    
    output = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]
    output_s.tt1 = output
    
    for i = 1:length(output)
        MLoutput(i,1) = {[output_s.tt1{i}./30303]};
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    
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
    
    % Plot filtered tts
    
    
    %% Get spikes from recording
    
    
    ms.fspiketimes     % get spike times from firings.mda
    
    
    %% build output struct
    
    output = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]
    output_s.tt2 = output

    for i = 1:length(output)
        MLoutput(i,2) = {[output_s.tt2{i}./30303]};
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% Importing data
    % Import dependencies
    
    tt = 'tt3'
    
    cd(firingsfolders)
    firings = readmda(sprintf('%s/raw/firings.mda',tt));
    MouseSessionraw = sprintf('%s\\%s\\%s\\%s.mda',msfolder,rec,tt,tt);
    addpath(MouseSessionraw);
    
    
    %%
    % firings = readmda('firings.mda'); %import firings.mda
    raw = readmda('raw.mda'); % import raw data
    ms = ms_objects(raw,firings);
    ms.fspiketimes     % get spike times from firings.mda
    
    % ms.bandpassfilter(l,h)
    ms.hpf(600);
    ms.lpf(3000);
    
    
    
    %% Get spikes from recording
    
    
    ms.fspiketimes     % get spike times from firings.mda
    
    
    %% build output struct
    
    output = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]
    output_s.tt3 = output
    
    for i = 1:length(output)
        MLoutput(i,3) = {[output_s.tt3{i}./30303]};
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% Importing data
    % Import dependencies
    
    tt = 'tt4'
    
    cd(firingsfolders)
    firings = readmda(sprintf('%s/raw/firings.mda',tt));
    MouseSessionraw = sprintf('%s\\%s\\%s\\%s.mda',msfolder,rec,tt,tt);
    addpath(MouseSessionraw);
    
    
    
    %%
    % firings = readmda('firings.mda'); %import firings.mda
    raw = readmda('raw.mda'); % import raw data
    ms = ms_objects(raw,firings);
    ms.fspiketimes     % get spike times from firings.mda
    
    
    
    
    
    %% Get spikes from recording
    
    
    ms.fspiketimes     % get spike times from firings.mda
    
    
    
    %% build output struct
    
    output = [ms.spiketimes,ms.spikes1,ms.spikes2,ms.spikes3,ms.spikes4]
    output_s.tt4 = output
    
    for i = 1:length(output)
        MLoutput(i,4) = {[output_s.tt4{i}./30303]};
    end
    %% Export timestamps for Neuroexplorer
    
    cd ..
    output_nex = struct2cell(output_s);
    output_nex = [output_nex{1}(:,1);output_nex{2}(:,1);output_nex{3}(:,1);output_nex{4}(:,1)];
    output_names = cell(length(output_nex),1);
    for i = 1:length(output_nex)
        output_names{i} = zeros(length(output_nex{i}),1)+i;
    end
    
    output_nex = [output_names,output_nex];
    output_nex = cell2mat(output_nex);
    
    fileID = fopen('spiketimes.txt','w');
    formatSpec = '%d %f\n'
    [nrows ncols] = size(output_nex);
    for row = 1:nrows
        fprintf(fileID,formatSpec,output_nex(row,1),output_nex(row,2)./30303);
    end
    fclose(fileID)
    
    % Save matlab structure output for spiketimes
    sfields = {'tt1','tt2','tt3','tt4'}
    MLoutput = cell2struct(MLoutput,sfields,2)
    save('spiketimes_ms.mat','MLoutput')
    
end
