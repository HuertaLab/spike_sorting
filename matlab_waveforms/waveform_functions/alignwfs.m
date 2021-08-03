function output = alignwfs(ms,rm,l)
% This function aligns the ms waveforms with spike2 waveforms by 
% removing 16 samples from the front and back (sampled at 10101)

[a b] = size(ms);

for i = 1:a
    for j = 1:b
        output{i,j} = ms{i,j}((1+rm)+1:l-(rm-1));
    end
end