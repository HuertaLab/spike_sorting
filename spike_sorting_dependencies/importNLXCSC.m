function [tt,fsc] = importNLXCSC(folder,ch_per_tt)

tt = [];
% All files within active folder
files = dir(folder);
i=1;
while i <length(files)
    if length(files(i).name)<3
        files(i) = [];
    else
        i=i+1;
    end
end 

% Sort to arrange in numerical order, use this sorting scheme below
CSC = zeros(ch_per_tt,1);
for i = 1:length(files)
    CSC(i) = str2num(cell2mat(regexp(files(i).name,'\d*','Match')));
end 
CSC = sort(CSC);
    
    
for i = 1:ch_per_tt
    sprintf('%s/CSC%d.ncs',folder,CSC(i))
    [TSc,fsc,csc_values,info] = Nlx2MatCSC_v3(sprintf('%s/%s',folder,files(i).name), [1 0 1 0 1], 1, 1, 1);
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
end