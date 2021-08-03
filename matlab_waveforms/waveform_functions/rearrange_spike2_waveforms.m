function [output] = rearrange_spike2_waveforms(S2)
% This function rearranges the outputted spike2 matlab structure into a
% format for easy analysis of waveforms to compare to mountainsrot
% cell with: {[times,waveforms1,wf2,wf3,wf4]} 
%each unit gets a row

% Get number of units to arrange new array
codes = S2.codes(:,1);
num_codes = unique(codes);
% set up output variable
output = cell(length(num_codes),5);

for i = 1:length(num_codes)
    output{i,1} = S2.times(codes == num_codes(i));
    output{i,2} = S2.values(codes == num_codes(i),:,1);
    output{i,3} = S2.values(codes == num_codes(i),:,2);
    output{i,4} = S2.values(codes == num_codes(i),:,3);
    output{i,5} = S2.values(codes == num_codes(i),:,4);
end 
