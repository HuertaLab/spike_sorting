classdef ms_objects < handle
    properties
        raw   % tetrode data from raw.mda
        firings    % firings from firings.mda
        t      % raw time for timeseries
        % timeseries for tt1_1:tt1_4
        tt1_1
        tt1_2
        tt1_3
        tt1_4
        fs    %samplingrate
        spiketimes
        spikes1 % spikes from tt1_1
        spikes2
        spikes3
        spikes4
        
        trackplot_output
        placefields
        orders
        firing_rates

    end
    
    methods
        function obj = ms_objects(data,firings)
            obj.fs = 30303;
            obj.raw = data;
            % time vector for raw data
            obj.t = [1:length(obj.raw)];
            obj.t = obj.t./obj.fs;
            obj.tt1_1 = timeseries(obj.raw(1,:),obj.t,'Name','tt1_1');
            obj.tt1_2 = timeseries(obj.raw(2,:),obj.t,'Name','tt1_2');
            obj.tt1_3 = timeseries(obj.raw(3,:),obj.t,'Name','tt1_3');
            obj.tt1_4 = timeseries(obj.raw(4,:),obj.t,'Name','tt1_4');
            obj.firings = firings;
            obj.tt1_1.Data = squeeze(obj.tt1_1.Data);
            obj.tt1_2.Data = squeeze(obj.tt1_2.Data);
            obj.tt1_3.Data = squeeze(obj.tt1_3.Data);
            obj.tt1_4.Data = squeeze(obj.tt1_4.Data);
        end
        
        function downsample(obj,r)
            t2 = obj.t(1:r:end);
            x = resample(obj.tt1_1.Data,1,r);
            obj.tt1_1 = timeseries(x,t2,'Name','tt1_1');
            x = resample(obj.tt1_2.Data,1,r);
            obj.tt1_2 = timeseries(x,t2,'Name','tt1_2');
            x = resample(obj.tt1_3.Data,1,r);
            obj.tt1_3 = timeseries(x,t2,'Name','tt1_3');
            x = resample(obj.tt1_4.Data,1,r);
            obj.tt1_4 = timeseries(x,t2,'Name','tt1_4');
            obj.fs = obj.fs/r;
            for i = 1:length(obj.spiketimes)
                obj.spiketimes{i} = double(int32(obj.spiketimes{i}/r));
            end
        end

%         function bandpassfilter(obj,l,h)
%             D = designfilt('bandpassiir','FilterOrder',2, 'HalfPowerFrequency1',l,...
%                 'HalfPowerFrequency2',h,'SampleRate', obj.fs);
%             obj.tt1_1.Data = filtfilt(D,obj.tt1_1.Data);
%             obj.tt1_2.Data = filtfilt(D,obj.tt1_2.Data);
%             obj.tt1_3.Data = filtfilt(D,obj.tt1_3.Data);
%             obj.tt1_4.Data = filtfilt(D,obj.tt1_4.Data);
%             
%         end
        
        function hpf(obj,fc)
            [b,a] = butter(2, fc/(obj.fs/2),'high');
            obj.tt1_1.Data = filtfilt(b,a,double(obj.tt1_1.Data));
            obj.tt1_2.Data = filtfilt(b,a,double(obj.tt1_2.Data));
            obj.tt1_3.Data = filtfilt(b,a,double(obj.tt1_3.Data));
            obj.tt1_4.Data = filtfilt(b,a,double(obj.tt1_4.Data));
        end
        
        function lpf(obj,fc)
            [b,a] = butter(2, fc/(obj.fs/2),'low');
            obj.tt1_1.Data = filtfilt(b,a,double(obj.tt1_1.Data));
            obj.tt1_2.Data = filtfilt(b,a,double(obj.tt1_2.Data));
            obj.tt1_3.Data = filtfilt(b,a,double(obj.tt1_3.Data));
            obj.tt1_4.Data = filtfilt(b,a,double(obj.tt1_4.Data));
        end
            
        function plot_tts(obj)
            figure
            subplot(4,1,1)
            reduce_plot(obj.tt1_1)
            subplot(4,1,2)
            reduce_plot(obj.tt1_2)
            subplot(4,1,3)
            reduce_plot(obj.tt1_3)
            subplot(4,1,4)
            reduce_plot(obj.tt1_4)
        end
        
        function fspiketimes(obj)
            xts = obj.firings;
            id = xts(3,:)';   % pull out spike ids
            PCt = xts(2,:)';   % pull out spike timestamps
            
            n = max(id);    % max of id = number of cells
            
            output = cell(1,n);
            
            for i = 1:n
                output{i} = PCt(id==i);
            end
            output = output'
            obj.spiketimes = output;
        end
        
        function removeendspikes(obj)    %Remove spikes right at beginning or end (too little time to construct spike)
           for i = 1:length(obj.spiketimes)
               while obj.spiketimes{i}(1) < (0.005*obj.fs)
                   obj.spiketimes{i}(1) = [];
               end
               while obj.spiketimes{i}(end) > ((obj.tt1_1.Time(end)*obj.fs)-(0.005*obj.fs))
                   obj.spiketimes{i}(end) = [];
               end
           end
        end
        
        function pullspikes(obj,hw1,hw2)   % get spikes from csc recordings from times in firings.mda
            n = length(obj.spiketimes);
            obj.spikes1 = cell(n,1);
            obj.spikes2 = cell(n,1);
            obj.spikes3 = cell(n,1);
            obj.spikes4 = cell(n,1);
            
            for i = 1:n
                st = obj.spiketimes{i};
                for j = 1:length(st)
                    obj.spikes1{i}(j,:) = squeeze(obj.tt1_1.Data(st(j)-int32((hw1*obj.fs)):st(j)+int32((hw2*obj.fs))));
                    obj.spikes2{i}(j,:) = squeeze(obj.tt1_2.Data(st(j)-int32((hw1*obj.fs)):st(j)+int32((hw2*obj.fs))));
                    obj.spikes3{i}(j,:) = squeeze(obj.tt1_3.Data(st(j)-int32((hw1*obj.fs)):st(j)+int32((hw2*obj.fs))));
                    obj.spikes4{i}(j,:) = squeeze(obj.tt1_4.Data(st(j)-int32((hw1*obj.fs)):st(j)+int32((hw2*obj.fs))));
                end
            end
            disp done
        end
        
        function plotspikes(obj,unit,num_examples)   % input unit and number of examples
        
            if num_examples > length(obj.spikes1{unit})
                num_examples = length(obj.spikes1{unit});
                disp 'All spikes'
            end
            lw = 5;
            [~,ot] = size(obj.spikes1{1});   % time window for spike overlay
            ot = [1:ot];                    % time window for spike overlay
            
            figure
            subplot(2,2,1)
            wf = obj.spikes1{unit};          % get all waveforms for a spike
            wfcentroid = mean(wf);         % get centroid (mean)
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold on
            for i=1:num_examples
                [~,w] = size(wf);
                l = int32(rand*w);
                if l == 0
                    l = l+1;
                end
                plot(wf(l,:),'k')
            end
            plot(ot,wfcentroid,'b','LineWidth',lw)

            hold off
            
            subplot(2,2,2)
            wf = obj.spikes2{unit};          % get all waveforms for a spike
            wfcentroid = mean(wf);         % get centroid (mean)
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold on
            for i=1:num_examples
                [~,w] = size(wf);
                l = int32(rand*w);
                if l == 0
                    l = l+1;
                end
                plot(wf(l,:),'k')
            end
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold off
            
            subplot(2,2,3)
            wf = obj.spikes3{unit};          % get all waveforms for a spike
            wfcentroid = mean(wf);         % get centroid (mean)
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold on
            for i=1:num_examples
                [~,w] = size(wf);
                l = int32(rand*w);
                if l == 0
                    l = l+1;
                end
                plot(wf(l,:),'k')
            end
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold off
            
            subplot(2,2,4)
            wf = obj.spikes4{unit};          % get all waveforms for a spike
            wfcentroid = mean(wf);         % get centroid (mean)
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold on
            for i=1:num_examples
                [~,w] = size(wf);
                l = int32(rand*w);
                if l == 0
                    l = l+1;
                end
                plot(wf(l,:),'k')
            end
            plot(ot,wfcentroid,'b','LineWidth',lw)
            hold off
            %             r1= 1                           % i th spike - r1 to r2
%             r2=100
%             
%             figure
%             subplot(2,2,1)
%             plot(ot,ms.spikes1{unit}(r1:r2,:))
%             subplot(2,2,2)
%             plot(ot,ms.spikes2{unit}(r1:r2,:))
%             subplot(2,2,3)
%             plot(ot,ms.spikes3{unit}(r1:r2,:))
%             subplot(2,2,4)
%             plot(ot,ms.spikes4{unit}(r1:r2,:))
        end

         
        function trackplot(obj,pos_data,t1,t2)

            addpath(genpath('/home/yes/MATLAB/mountainsort convert to mda'))
            MouseSession = pos_data;
            cd(MouseSession)
            [t, x, y] = Nlx2MatVT_v3('VT1.nvt', [1 1 1 0 0 0], 0, 1, []);
            which Nlx2MatVT_v3;   
            [Event_TS, EventStrings] = Nlx2MatEV_v3('Events.nev', [1 0 0 0 1], 0,1,[]);
            which Nlx2MatEv_v3
            timeoffset = Event_TS(1);
            t = (t - timeoffset)./1000000;

            a=t1;
            b=t2;
            boxsize = 80
            
            xboundmin = 10;
            xboundmax = 800;
            yboundmin = 15;
            yboundmax = 800;
            
            % Remove bad points
            
            i = 2;
            while i <= length(t);
                if x(i) <= 10;
                    x(i) = x(i-1);
                    y(i) = y(i-1);
                end
                i = i+1;
            end
            
            maxy = max(y);
            miny = min(y);
            yrange = maxy-miny;
            
            maxx = max(x);
            minx = min(x);
            xrange = max(x);
            range = [xrange,yrange];
            range = mean(range);
            
            % ADJUST ACCORDINGLY
            sizeratio = yrange/boxsize
            x = x-min(x);
            y = y-min(y);
%             figure
%             scatter(x,y)

            for i = 2:length(t)
                if x(i) < xboundmin
                    x(i) = x(i-1);
                    y(i) = y(i-1);
                end
                if x(i) > xboundmax
                    x(i) = x(i-1);
                    y(i) = y(i-1);
                end
                
                if y(i) < yboundmin
                    x(i) = x(i-1);
                    y(i) = y(i-1);
                end
                if y(i) > yboundmax
                    x(i) = x(i-1);
                    y(i) = y(i-1);
                end
            end
            
            
            figure
            scatter(x,y)
             
            i = 1;
            v= zeros(1,length(t));
            for i = 2:length(t);
                dx(i) = x(i)-x(i-1);
                dy(i) = y(i)-y(i-1);
                dt(i) = t(i)-t(i-1);
            end
            
            v = (sqrt((dx.^2 + dy.^2)))./dt;
            v = v./sizeratio;
            torig = t;
            
            i = 1;
            for i= 1:length(v);
                if v(i) >= 30;
                    v(i) = 30;
                    t(i) = -100;
                end
            end
            
            v = v(v~=30);
            
            t = t(t~=-100);
%             figure
%             plot(t,v)
            hold on
            xlabel('time(s)')
            ylabel('speed (cm/s)')
            hold off
            
            v = v(t<b);
            t = t(t<b);
            v = v(t>a);
            t = t(t>a);
            
%             figure
%             histogram(v,60)
            ax=gca;
            ax.XTickMode = 'manual';
            ax.XTick = [0:10:120];
            xlabel('speed cm/s')
            
            v2 = histcounts(v,100);
            
            [~,speed] = max(v2);
            speed = speed-1
            
            if speed == 0
                vsecond = v2;
                vsecond(1) = 0;
                [~,speed] = max(vsecond);
                speed_fixed = speed-1
            end
            
            d=[t',v'];
            c=[torig',x',y'];
            
            obj.trackplot_output = c;
        end
        
        function LT(obj,firings)
                        
            x = firings; %import firings.mda
            id = x(3,:)';   % pull out spike ids
            PCt = x(2,:)';   % pull out spike timestamps
            
            n = max(id);    % max of id = number of cells
            
            output = cell(1,n);
            
            for i = 1:n
                output{i} = PCt(id==i)
            end
            
%             output_table = cell2table(output);
            
%             writetable(output_table,'output.csv')
            
            
            %
            % Input times here
            
            % Encoding window
            t1 = 1
            t2 = 1200
            
            % Decoding Window
            ta = 1
            tb = 1200
            
            
            box = 120
            bins_stem = 40
            
            ltends = 3;
            ltends = ltends*2;
            bins_all = bins_stem+ltends;
           
            
            
            gs = fspecial('gaussian',5,1);
            
            % Constants for continuity constraint
            
            % d - .5 for random walk, 1 for linear motion
            d = 1
            
            % Proportional to radius
            K = 8;
            V = 12;
            % Intensity
            C = 5;
          
            codes = id;
            PCt_bup = PCt;
            
            
            codes = codes(PCt ~= 0);
            
            PCt = PCt./30303;
            PCt = PCt(PCt ~= 0);
            
            
            SO = [obj.trackplot_output(:,1),obj.trackplot_output(:,2)];
            rt = SO(:,1);
            rx = SO(:,2);
            ry = ones([length(rx),1]);
            fs = 1./(rt(30)./30)
            
            
            % Only take coordinates from encoding times
            rx_wholesession = rx;
            rt_wholesession = rt;
            
            rx = rx(rt>t1);
            ry = ry(rt>t1);
            rt = rt(rt>t1);
            
            rx = rx(rt<t2);
            ry = ry(rt<t2);
            rt = rt(rt<t2);
            
            
            % Get speed data from coordinates
            
            xrange = max(rx)-min(rx);
            sizeratio = xrange/box
            
            v= zeros(1,length(rt));
            for i = 2:length(rt);
                dx(i) = rx(i)-rx(i-1);
                dvt(i) = rt(i)-rt(i-1);
            end
            v(1) = v(2);
            v = dx./dvt;
            v = v./sizeratio;
            v = abs(v);
            % Filter spikes to those only when the animal is moving over 1.5 cm/s
            rtcell1 = zeros(1,2);
            rtcell2 = zeros(1,2);
            i = 1;
            
            
            % Align spike and camera times
            
            while i < length(codes)
                cv = PCt(i);
                if i == 1
                    if rt(i)>=cv(i)
                        i = i+1;
                        continue
                    end
                elseif i == length(codes)
                    if cv(end)>=rt(end)
                        i = i+1;
                        continue
                    end
                end
                if isempty(rt(rt>cv)) == 1
                    i = i+1;
                    continue
                end
                if isempty(rt(rt<cv)) == 1
                    i = i+1;
                    continue
                end
                
                [rtcell1(1), rtcell1(2)] = min(rt(rt>cv)); % fancy way of deciding spike times
                [rtcell2(1), rtcell2(2)] = max(rt(rt<cv));
                
                if abs(rtcell1(1)-cv)<abs(rtcell2(1)-cv)
                    rtcell = rtcell1;
                else
                    rtcell = rtcell2;
                end
                if v(rtcell(2))<1.5
                    codes(i) = [];
                    PCt(i) = [];
                    i = i-1;
                end
                i = i+1;
            end
            clear rtcell1 rtcell2
            
       
            
            % Convert position data to bins
            
            rxbins = rx./max(rx).*bins_all;
            
            x = discretize(rxbins, 0:1:bins_all);
            
            % Filter position data for speed
            rxbins_vfilt= rxbins(v>1.5);
            
            xfilt = discretize(rxbins_vfilt, 0:1:bins_all);
            yfilt = ones([length(xfilt),1]);
            SO = zeros(bins_all,1);
            
            % Time Spent heat map
            yh = yfilt;
            for i = 1:bins_all
                xh = xfilt;
                xh(xh~=i) = 0;
                z = xh;
                z = z(z>0);
                SO(i) = length(z);
            end
            Position = SO./fs;
            % Spatial occupancy
            SO = SO./(sum(sum(SO)));
            
                        
            % Place Fields
            % N - total number of Place Cells
            
            endSpike_Counts = {};
            
            % Number of spikes
            
            for j = 1:max(unique(codes))
                spikes = zeros(bins_all,1);
                PCt_code = PCt(codes == j); % PCt_code - spikes times for each code
                for i = 1:length(PCt_code)
                    t = rt(rt<PCt_code(i));
                    [t,tin] = max(t);
                    PFx = x(tin);
                    spikes(PFx) = spikes(PFx)+1;
                end
                Spike_Counts{j} = spikes;
                PF = spikes./Position;
                PF(isnan(PF) == 1) = 0;
                Place_Fields{j} = PF;
                
            end
            
            % Remove ends
            
            for i = 1:length(Place_Fields)
                pf = Place_Fields{i};
                pf = pf(1+ltends/2:bins_all-ltends/2,1);
                Place_Fields{i} = pf;
            end
            
            
            % Gaussian Smoothing on PF
            
            for i = 1:length(Place_Fields)
                Place_Fields{i} = filter2(gs,Place_Fields{i});
            end
            
            % Place field maps
            LT_Place_Fields = zeros(bins_stem,length(Place_Fields));
            
            for i = 1:length(Place_Fields)
                LT_Place_Fields(:,i) = Place_Fields{i}./max(Place_Fields{i});
            end
            
            pf = LT_Place_Fields;
            
%             figure
%             plot(Place_Fields{12})
%             
            
            [~,COM] = max(pf);
            
            pf = [COM;pf]
            [~, order] = sort(pf(1,:));
            pf = pf(:,order);
    
            
            pf(1,:) = [];
            
            pf = [pf,pf(:,1)]
            
            figure
            pcolor(pf')
            hold on
            caxis([0.4 1])
            hold off
                
            obj.orders = order';
            obj.placefields = pf;
            disp(obj.orders)
        end
        
        function frs(obj)   %firing rates for all units
           for i = 1:length(obj.spikes1)
               obj.firing_rates(i) = length(obj.spikes1{i})/max(obj.tt1_1.Time);
           end
           obj.firing_rates = obj.firing_rates';
           disp(obj.firing_rates)
       end
    end
end