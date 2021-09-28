clear 
close all
clc

%% YOUR DATA FOLDER HERE
msfolder = '/home/loinn/Documents/testdata/'
%% Number of tetrodes
num_tts = 4;
%% Sampling rate
fs = 30303;
%% Add dependencies
addpath(genpath('/home/loinn/MATLAB/spike_sorting_dependencies'))
%%
cd(msfolder)
folders = dir;
mouse_day = cell(length(folders)-2,1)
j=1;
for i=3:length(folders)
        mouse_day{j} = folders(i).name;
        j=j+1;
end

    
%% Run through each mouse_day
for ifolder = 1:length(folders)
    cd(msfolder)
    rec = folders(ifolder);
    if length(rec.name)<3
        continue
    else
        rec = rec.name
    end
    
    % Get sessions
    session= {};
    j = 1;
    session_folders = dir(rec);
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
    % Import info for each recording time to split
    tt_info = csvread(sprintf('%s/%s/tt1/tt1.mda/t_info.csv',msfolder,rec));
    
    %% Import data from each tetrode 
    % Set up output variable
    IDs_spiketimes = cell(num_tts,1);
    for tet = 1:num_tts
        tt = sprintf('tt%d',tet);
        % Import firings and raw data
        firingsfolders = sprintf('%s%s/output',msfolder,rec);
        firings = readmda(sprintf('%s%s/output/%s/raw/firings.mda',msfolder,rec,tt)); 
        firings = getspiketimes(firings);
        firings = cell2mat(firings);
        firings(:,2) = firings(:,2)./fs;
        IDs_spiketimes{tet} = firings;
    end
    
    %% Assign new ID for tetrodes after first to prevent conflicts
    maxID = 0;
    if length(IDs_spiketimes) > 2
        for i = 1:length(IDs_spiketimes)
            if isempty(IDs_spiketimes{i}) == 1
                continue
            end
            IDs_spiketimes{i}(:,1) = IDs_spiketimes{i}(:,1) + maxID;
            if isempty(IDs_spiketimes{i}) == 0
                maxID = max(IDs_spiketimes{i}(:,1));
            end
        end
    end
        
    %% Export timestamps for Neuroexplorer
    clear output_nex
    output_nex = cell2mat(IDs_spiketimes);
    
    for i = 1:size(tt_info,1)
        writedir = sprintf('%s%s/%s',msfolder,rec,session{i});
        outfile = output_nex(output_nex(:,2)>tt_info(i,1) & output_nex(:,2)<tt_info(i,2),:)
        outfile(:,2) = outfile(:,2)-tt_info(i,1)
        fileID = fopen(sprintf('%s/spiketimes.txt',writedir),'w');
        formatSpec = '%d %f\n'
        nrows = size(outfile,1);
        for row = 1:nrows
            fprintf(fileID,formatSpec,outfile(row,1),outfile(row,2));
        end
        fclose(fileID);
        cd ..
        clear outfile
    end
    
end

disp done
