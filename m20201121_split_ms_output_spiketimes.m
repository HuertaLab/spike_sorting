clear all
close all
clc

%% YOUR DATA FOLDER HERE
msfolder = '/media/loinn/Windows_linux/Mountainsort/JoeTMazeMerge/'
%%
    cd(msfolder)

folders = dir;


j=1;
for i=1:length(folders)
    if length(folders(i).name)>2
        mouse_day{j} = folders(i).name
        j=j+1;
    else 
        continue
    end
end

    
for ifolder = 1:length(folders)
    cd(msfolder)
    rec = folders(ifolder);
    if length(rec.name)<3
        continue
    else
        rec = rec.name
    end
    
    clear MLoutput
    
    cd(rec)
    
  
    
    session= {};
    j = 1;
    session_folders = dir;
    for i = 1:length(session_folders)
        if length(session_folders(i).name) >2
            if contains(session_folders(i).name,["output","tt"])==0
                session{j} = session_folders(i).name
                j = j+1;
            else
                continue
            end
        end
    end

    tt_info = csvread(sprintf('%s/%s/tt1/tt1.mda/t_info.csv',msfolder,rec));
    
    %% Importing data
    % Import dependencies
    
    
    tt = 'tt1'
    
    addpath('/home/loinn/MATLAB/ms_matlab')
    addpath(genpath('/home/loinn/MATLAB/mountainsort convert to mda'))
    addpath(genpath('/home/loinn/MATLAB/matlab-plot-big'))
    
    % Import firings and raw data
    firingsfolders = sprintf('%s%s/output',msfolder,rec)
    cd(firingsfolders)
    firings = readmda(sprintf('%s%s/output/%s/raw/firings.mda',msfolder,rec,tt));
    MouseSessionraw = sprintf('%s%s/%s/%s.mda',msfolder,rec,tt,tt);
    addpath(MouseSessionraw);
    addpath(pwd);
    pos_data = sprintf('%s%s/',msfolder,rec);
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
    
    
    
    %% build output struct
    
    output = ms.spiketimes
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
    MouseSessionraw = sprintf('%s%s/%s/%s.mda',msfolder,rec,tt,tt);
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
    MouseSessionraw = sprintf('%s%s/%s/%s.mda',msfolder,rec,tt,tt);
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
    MouseSessionraw = sprintf('%s%s/%s/%s.mda',msfolder,rec,tt,tt);
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
    
    % Split for txt file output
    output_nex(:,2) = output_nex(:,2)./30303
    
    for i = 1:length(tt_info)
        cd(session{i})
        clear outfile
        outfile = output_nex(output_nex(:,2)>tt_info(i,1) & output_nex(:,2)<tt_info(i,2),:)
        outfile(:,2) = outfile(:,2)-tt_info(i,1)
        fileID = fopen('spiketimes.txt','w');
        formatSpec = '%d %f\n'
        [nrows ncols] = size(outfile);
        for row = 1:nrows
            fprintf(fileID,formatSpec,outfile(row,1),outfile(row,2));
        end
        fclose(fileID)
        cd ..
    end
    
    
%     
%     
% %     Save matlab structure output for spiketimes
%     sfields = {'tt1','tt2','tt3','tt4'}
%     MLoutput = cell2struct(MLoutput,sfields,2)
%     save('spiketimes_ms.mat','MLoutput')
    
end

disp done
