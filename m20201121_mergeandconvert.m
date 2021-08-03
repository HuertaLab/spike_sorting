clear
close all
clc
%% INPUT YOUR FOLDER HERE
parent = '/media/loinn/Windows_linux/Mountainsort/JoeTMaze/'
%% Dependencies
addpath(genpath('/home/loinn/MATLAB/mountainsort convert to mda'))
geom = [0 0; 20 0; 0 20; 20 20];

%% Loop to organzie all folders within parent directory
cd(parent)
folders = dir;
for ifolder= 1:length(folders)
    % Files organized by mouse_day and then by session
    % Choose each mouse_day
    Mouse_day = folders(ifolder);
    if length(Mouse_day.name)>2
        Mouse_day = sprintf('%s%s',parent,Mouse_day.name)
    else
        continue
    end
    
    % Change directory to mouse_day
    cd(Mouse_day)
    
    % Convert files, one tetrode at a time and then by each session per day
    
    % Choose each session (within each mouse_day)
    Sessions_day = dir;
    
    % Set up counter for number of sessions per day
    session_count = 0;
    session_dir = {};
    
    % Set up merged tetrode variables
    tt1 = [];
    tt2 = [];
    tt3 = [];
    tt4 = [];
    
    for jfolder = 1:length(Sessions_day)
        session = Sessions_day(jfolder)
        if length(session.name)>2
            session = sprintf('%s/%s',Mouse_day,session.name)
        else
            continue
        end
        
        cd(session)
        
        
        % Organize by tetrode (only first time)
        % Create folder for each tetrode and add appropriate CSC files
        mkdir tt1
        movefile CSC1.ncs tt1
        movefile CSC2.ncs tt1
        movefile CSC3.ncs tt1
        movefile CSC4.ncs tt1
        
        mkdir tt2
        movefile CSC5.ncs tt2
        movefile CSC6.ncs tt2
        movefile CSC7.ncs tt2
        movefile CSC8.ncs tt2
        
        mkdir tt3
        movefile CSC9.ncs tt3
        movefile CSC10.ncs tt3
        movefile CSC11.ncs tt3
        movefile CSC12.ncs tt3
        
        mkdir tt4
        movefile CSC13.ncs tt4
        movefile CSC14.ncs tt4
        movefile CSC15.ncs tt4
        movefile CSC16.ncs tt4
    end
        
    cd(Mouse_day)
    
    % All sessions for tetrode 1
    for jfolder = 1:length(Sessions_day)
        % Pick session
        session = Sessions_day(jfolder)
        if length(session.name)>2
            session = sprintf('%s/%s',Mouse_day,session.name)
        else
            continue
        end
        
        cd(session)
        
        % get csc data for first tetrode
        
        cd tt1    % Set tt as pwd and make output dir
        
        tt = [];
        % All files within active folder
        files = dir('*.ncs')
        for i = 1:4
            [TSc,fsc,csc_values,info] = Nlx2MatCSC_v3(files(i).name, [1 0 1 0 1], 1, 1, 1);
            which Nlx2MatCSC_v3;
            ADBV = strfind(info,'-ADBitVolts');
            ADBV = find(~cellfun(@isempty,ADBV));
            ADBV = info(ADBV);
            ADBV = regexprep(ADBV,'-ADBitVolts','');
            ADBV = str2double(ADBV);
            fsc = fsc(1);
            csc_values = reshape(csc_values,1,numel(csc_values));
            csc_values = csc_values.*ADBV;
            tt(:,i) = csc_values;
        end
        %Save converted output as mda
        tt = tt';
        tt1 = [tt1,tt];
    end
    
    % Change back to mouse_day directory
    cd(Mouse_day)
    
    % All sessions for tetrode 2
    for jfolder = 1:length(Sessions_day)
        % Pick session
        session = Sessions_day(jfolder)
        if length(session.name)>2
            session = sprintf('%s/%s',Mouse_day,session.name)
        else
            continue
        end
        
        cd(session)
        
        % get csc data for second tetrode
        
        cd tt2    % Set tt as pwd and make output dir
        
        tt = [];
        % All files within active folder
        files = dir('*.ncs')
        for i = 1:4
            [TSc,fsc,csc_values,info] = Nlx2MatCSC_v3(files(i).name, [1 0 1 0 1], 1, 1, 1);
            which Nlx2MatCSC_v3;
            ADBV = strfind(info,'-ADBitVolts');
            ADBV = find(~cellfun(@isempty,ADBV));
            ADBV = info(ADBV);
            ADBV = regexprep(ADBV,'-ADBitVolts','');
            ADBV = str2double(ADBV);
            fsc = fsc(1);
            csc_values = reshape(csc_values,1,numel(csc_values));
            csc_values = csc_values.*ADBV;
            tt(:,i) = csc_values;
        end
        %Save converted output as mda
        tt = tt';
        tt2 = [tt2,tt];
    end
    
    % Change back to mouse_day directory
    cd(Mouse_day)
    
    % All sessions for tetrode 3
    for jfolder = 1:length(Sessions_day)
        % Pick session
        session = Sessions_day(jfolder)
        if length(session.name)>2
            session = sprintf('%s/%s',Mouse_day,session.name)
        else
            continue
        end
        
        cd(session)
        
        % get csc data for second tetrode
        
        cd tt3    % Set tt as pwd and make output dir
        
        tt = [];
        % All files within active folder
        files = dir('*.ncs')
        for i = 1:4
            [TSc,fsc,csc_values,info] = Nlx2MatCSC_v3(files(i).name, [1 0 1 0 1], 1, 1, 1);
            which Nlx2MatCSC_v3;
            ADBV = strfind(info,'-ADBitVolts');
            ADBV = find(~cellfun(@isempty,ADBV));
            ADBV = info(ADBV);
            ADBV = regexprep(ADBV,'-ADBitVolts','');
            ADBV = str2double(ADBV);
            fsc = fsc(1);
            csc_values = reshape(csc_values,1,numel(csc_values));
            csc_values = csc_values.*ADBV;
            tt(:,i) = csc_values;
        end
        %Save converted output as mda
        tt = tt';
        tt3 = [tt3,tt];
    end
    
    
    
    % Change back to mouse_day directory
    cd(Mouse_day)
    
    
    % All sessions for tetrode 4
    for jfolder = 1:length(Sessions_day)
        % Pick session
        session = Sessions_day(jfolder)
        if length(session.name)>2
            session = sprintf('%s/%s',Mouse_day,session.name)
        else
            continue
        end
        
        cd(session)
        
        % get csc data for second tetrode
        
        cd tt4    % Set tt as pwd and make output dir
        
        tt = [];
        % All files within active folder
        files = dir('*.ncs')
        for i = 1:4
            [TSc,fsc,csc_values,info] = Nlx2MatCSC_v3(files(i).name, [1 0 1 0 1], 1, 1, 1);
            which Nlx2MatCSC_v3;
            ADBV = strfind(info,'-ADBitVolts');
            ADBV = find(~cellfun(@isempty,ADBV));
            ADBV = info(ADBV);
            ADBV = regexprep(ADBV,'-ADBitVolts','');
            ADBV = str2double(ADBV);
            fsc = fsc(1);
            csc_values = reshape(csc_values,1,numel(csc_values));
            csc_values = csc_values.*ADBV;
            tt(:,i) = csc_values;
        end
        %Save converted output as mda
        tt = tt';
        tt4 = [tt4,tt];
    end

    % Change back to mouse_day directory
    cd(Mouse_day)
    
    % Get time data for start and end of each session
    session_length = [];
    s_count = 1;
     for jfolder = 1:length(Sessions_day)
        % Pick session
        session = Sessions_day(jfolder)
        if length(session.name)>2
            session = sprintf('%s/%s',Mouse_day,session.name)
        else
            continue
        end
        
        cd(session)
        cd tt1
        [TSc,fsc,csc_values,info] = Nlx2MatCSC_v3('CSC1.ncs', [1 0 1 0 1], 1, 1, 1);
        which Nlx2MatCSC_v3;
        fsc = fsc(1);
        csc_values = reshape(csc_values,1,numel(csc_values));
        session_length(s_count) = length(csc_values)/fsc;
        s_count = s_count+1;
     end
     
     % Set up tt_info variable to get start and end times for each session
     tt_info = [];
     tt_info(1,1) = 0;
     tt_info(1,2) = session_length(1)
     for k = 2:s_count-1
         tt_info(k,1) = tt_info(k-1,2)
         tt_info(k,2) = tt_info(k,1)+session_length(k)
     end
         
    cd(Mouse_day)
    
    
    % Set up mouse_day folder        Make tt directories at this level
    mkdir tt1
    mkdir('tt1','tt1.mda')
    mkdir tt2
    mkdir('tt2','tt2.mda')
    mkdir tt3
    mkdir('tt3','tt3.mda')
    mkdir tt4
    mkdir('tt4','tt4.mda')
    
    cd tt1
    cd tt1.mda
    writemda(tt1,'raw.mda')
    csvwrite('t_info.csv',tt_info)
    csvwrite('geom.csv',geom)
    fileID = fopen('params.json','w');
    fprintf(fileID,'{\n"samplerate":30303,\n"spike_sign":1\n}','params.json');
    fclose(fileID)
    cd(Mouse_day)
    
    cd tt2
    cd tt2.mda
    writemda(tt2,'raw.mda')
    csvwrite('t_info.csv',tt_info)
    csvwrite('geom.csv',geom)
    fileID = fopen('params.json','w');
    fprintf(fileID,'{\n"samplerate":30303,\n"spike_sign":1\n}','params.json');
    fclose(fileID)
    cd(Mouse_day)
    
    cd tt3
    cd tt3.mda
    writemda(tt3,'raw.mda')
    csvwrite('t_info.csv',tt_info)
    csvwrite('geom.csv',geom)
    fileID = fopen('params.json','w');
    fprintf(fileID,'{\n"samplerate":30303,\n"spike_sign":1\n}','params.json');
    fclose(fileID)
    cd(Mouse_day)
    
    cd tt4
    cd tt4.mda
    writemda(tt4,'raw.mda')
    csvwrite('t_info.csv',tt_info)
    csvwrite('geom.csv',geom)
    fileID = fopen('params.json','w');
    fprintf(fileID,'{\n"samplerate":30303,\n"spike_sign":1\n}','params.json');
    fclose(fileID)
    cd(Mouse_day)
end

disp done