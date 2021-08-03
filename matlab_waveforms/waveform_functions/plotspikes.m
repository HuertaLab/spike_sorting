function plotspikes(spikes,unit,num_examples)   % input unit and number of examples

if num_examples > length(spikes{unit,1})
    num_examples = length(spikes{unit,1});
    disp 'All spikes'
end
lw = 5;
[~,ot] = size(spikes{unit,1});   % time window for spike overlay
ot = [1:ot];                    % time window for spike overlay

figure
subplot(2,2,1)
wf = spikes{unit,2};          % get all waveforms for a spike
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
wf = spikes{unit,3};          % get all waveforms for a spike
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
wf = spikes{unit,4};          % get all waveforms for a spike
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
wf = spikes{unit,5};          % get all waveforms for a spike
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