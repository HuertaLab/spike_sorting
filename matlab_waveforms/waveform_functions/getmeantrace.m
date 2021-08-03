function [output] = getmeantrace(spikes,m)
% Gets mean or median trace of each waveform
% 1 for mean 2 for median


if m ==1
    output = cell(size(spikes));
    output(:,5) = [];
    
    for i = 1:size(spikes,1)
        for j = 1:4
            output{i,j} = mean(spikes{i,j+1});
        end
    end
end

if m ==2
    output = cell(size(spikes));
    output(:,5) = [];
    
    for i = 1:size(spikes,1)
        for j = 1:4
            output{i,j} = median(spikes{i,j+1});
        end
    end
end