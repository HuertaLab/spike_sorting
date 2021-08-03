function plotwf(meanwf,unit,inputtitle)   % input unit and number of examples
% Takes mean or median waveform as input and plots

% Assign line width
lw = 3 ;

% Scale y axis
for i = 1:4
    h(i) = max(meanwf{unit,i});
    l(i) = min(meanwf{unit,i});
end
h = max(h);
l = min(l);
h = h+h*0.1;
l = l-h*0.1;


x = 1:length(meanwf{unit,1});
figure
subplot(2,2,1)
wf = meanwf{unit,1};        
plot(x,wf,'b','LineWidth',lw)
hold on
title(inputtitle)
ylim([l h])
hold off

subplot(2,2,2)
wf = meanwf{unit,2};          
plot(x,wf,'b','LineWidth',lw)
hold on
ylim([l h])
hold off 

subplot(2,2,3)
wf = meanwf{unit,3};          
plot(x,wf,'b','LineWidth',lw)
hold on
ylim([l h])
hold off

subplot(2,2,4)
wf = meanwf{unit,4};          
plot(x,wf,'b','LineWidth',lw)
hold on
ylim([l h])
hold off

end