clear
close all
clc
%% INPUT YOUR FOLDER HERE
parent = '/home/loinn/Documents/testdata/'
%% Indicate number of recording tetrodes
num_tts = 4;
% Indicate number of channels per n-trode
num_ch_per_tt = 4;
%% Add dependencies
addpath(genpath('/home/loinn/MATLAB/spike_sorting_dependencies'))
%% Geometry file
geom = [0 0; 20 0; 0 20; 20 20];

%% Merge and save mda file for each mouse on a tetrode-by-tetrode basis

% Naming variable for list for mountainsort input
sortlist = cell(2,1);
sortlist_output = cell(2,1);
isort = 1;

cd(parent)
folders = dir;
for ifolder= 3:length(folders)
    % Files organized by mouse_day and then by session
    % Choose each mouse_day
    Mouse_day = folders(ifolder);
    Mouse_day = sprintf('%s%s',parent,Mouse_day.name);
    % Change directory to mouse_day
    cd(Mouse_day)
    
    % Convert files, one tetrode at a time and then by each session per day
    
    % Choose each session (within each mouse_day)
    Sessions_day = dir;
    
    % Set up counter for number of sessions per day
    session_count = 0;
    session_dir = {};
    
   
    % Move CSCs to individual folder for each tetrode
    for jfolder = 3:length(Sessions_day)
        session = Sessions_day(jfolder);
        session = sprintf('%s/%s',Mouse_day,session.name);
        cd(session)
        
        iCSC = 1;
        % Organize by tetrode (only first time)
        % Create folder for each tetrode and add appropriate CSC files
        for itt = 1:num_tts
            mkdir(sprintf('tt%d',itt))
            for j = 1:num_ch_per_tt
                movefile(sprintf('CSC%d.ncs',iCSC),sprintf('tt%d',itt))
                iCSC = iCSC+1;
            end
        end
    end
    
    cd(Mouse_day)
    
    % On a tetrode-by-tetrode basis, import NLX data and create folder for
    % merged output
    for tet = 1:num_tts
        % make appropriate directory
        mkdir(sprintf('tt%d',tet))
        mkdir(sprintf('tt%d/tt%d.mda',tet,tet))
        % cell array (for single tetrode) to contain each session
        tt = cell(1,length(Sessions_day)-2);
        for jfolder = 3:length(Sessions_day)
            % Pick session
            session = Sessions_day(jfolder);
            session = sprintf('%s/%s',Mouse_day,session.name);
            % Import from each channel of the tetrode
            % Import csc data into tts varaible
            cscs_dir = sprintf('%s/tt%d',session,tet);
            [tt{jfolder-2},fsc] = importNLXCSC(cscs_dir,num_ch_per_tt);
        end
        % Merge Session_day data, get data for splitting,save output
        % Get data for split
        session_lengths = zeros(length(tt),1);
        for i = 1:length(tt)
            session_lengths(i) = size(tt{i},2)./fsc;
        end
        t_info = zeros(length(Sessions_day)-2,2);
        for i = 1:length(tt)
            t_info(i,2) = session_lengths(i);
            if i>1
                t_info(i,1) = session_lengths(i-1);
            end
        end
        % Save outputs
        tt = cell2mat(tt);
        csvwrite(sprintf('%s/tt%d/tt%d.mda/t_info.csv',Mouse_day,tet,tet),t_info)
        csvwrite(sprintf('%s/tt%d/tt%d.mda/geom.csv',Mouse_day,tet,tet),geom)
        fileID = fopen(sprintf('%s/tt%d/tt%d.mda/params.json',Mouse_day,tet,tet),'w');
        fprintf(fileID,'{\n"samplerate":30303,\n"spike_sign":1\n}','params.json');
        fclose(fileID);
        writemda(tt,sprintf('%s/tt%d/tt%d.mda/raw.mda',Mouse_day,tet,tet))
        % Create list for sorting to make mountainsort step easier
        sortlist{isort} = sprintf('%s/tt%d',Mouse_day,tet);
        sortlist_output{isort} = sprintf('%s/output',Mouse_day);
        isort = isort + 1;
    end
    mkdir('output')
end
%% Create list for mountainsort
cd(parent)
fileID = fopen('runsort.sh','w');
fprintf(fileID,...
    '#!/bin/bash\n\nexport NUM_WORKERS_PER_JOB=2\nexport MKL_NUM_THREADS=$NUM_WORKERS_PER_JOB\nexport NUMEXPR_NUM_THREADS=$NUM_WORKERS_PER_JOB\nexport OMP_NUM_THREADS=$NUM_WORKERS_PER_JOB\n\n')
for i = 1:length(sortlist)
    fprintf(fileID,sprintf(...
        '\n./sort_animal_day.py --input %s --output %s --num_jobs 1 --test $@',sortlist{i},sortlist_output{i}));
end
fclose(fileID) ;  
fileattrib('runsort.sh','+x')

disp done
