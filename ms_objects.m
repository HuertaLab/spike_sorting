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

         
      
        
        function frs(obj)   %firing rates for all units
           for i = 1:length(obj.spikes1)
               obj.firing_rates(i) = length(obj.spikes1{i})/max(obj.tt1_1.Time);
           end
           obj.firing_rates = obj.firing_rates';
           disp(obj.firing_rates)
       end
    end
end